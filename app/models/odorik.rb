OdorikAPIChangeCredsNotification = "Odorik#changeCreds"
OdorikAPIChangeLineNotification = "Odorik#changeLine"
OdorikAPIChangeCallerNotification = "Odorik#changeCaller"

class Odorik
	PERSISTENCE_KEY = 'odorik_api'
	SERVER = 'https://www.odorik.cz/api/v1/'
	TEST_SERVER = 'http://wejn.com/odorik_test_api___/'
	CLIENT_ID = 'com.wejn.Odorik'

	class << self
		def configured?; load!; !(@user.nil? || @pass.nil?); end
		def user; load!; @user; end
		def pass; load!; @pass; end
		def line; load!; @line; end
		def caller; load!; @caller; end # XXX: not strictly OdorikAPI's concern
		def caller=(_caller)
			@caller = _caller
			save!
			OdorikAPIChangeCallerNotification.post_notification
		end
		def line=(line)
			@line = line
			save!
			OdorikAPIChangeLineNotification.post_notification
		end

		def get_server(testing = false)
			if testing || (user == '888' && pass == '888')
				TEST_SERVER
			else
				SERVER
			end
		end
		private :get_server

		# make a sync call out of an async one
		def call_synchronized(method, *args)
			finished = false
			result = nil
			send(method, *args) do |res|
				result = res
				finished = true
			end
			sleep 0.1 until finished
			result
		end
		private :call_synchronized

		def verify(username, password, &b)
			return call_synchronized(:verify, username, password) if b.nil?

			pload = {user: username, password: password, user_agent: CLIENT_ID}
			s = get_server(username == '888' && password == '888')
			AFMotion::HTTP.get(s + 'balance', pload) do |resp|
				b.call(resp.success? && resp.body !~ /^error/)
			end
			self
		end

		def load!
			return true if @data_loaded

			ret = nil
			h = App::Persistence[PERSISTENCE_KEY]
			if h.kind_of?(Hash)
				@user = h[:user]
				@pass = h[:pass]
				@line = h[:line]
				@caller = h[:caller]
				@lines = h[:lines]
				@sms_allowed_sender = h[:sms_allowed_sender]
				ret = true
			else
				ret = false
			end
			@data_loaded = true
			ret
		end
		private :load!

		def reset!
			@data_loaded = true
			@user = @pass = @line = nil
			@balance = @lines = @sms_allowed_sender = nil
			@call_history = nil
			save!
			OdorikAPIChangeCredsNotification.post_notification
		end

		def save!
			return false if @disable_save
			h = {}
			h[:user] = @user if @user
			h[:pass] = @pass if @pass
			h[:line] = @line if @line
			h[:caller] = @caller if @caller
			h[:lines] = @lines if @lines
			h[:sms_allowed_sender] = @sms_allowed_sender if @sms_allowed_sender
			# XXX: if you find this^^ stupid, then store NilClass or Symbol
			# in App::Persistence. Go on, I'll wait.
			App::Persistence[PERSISTENCE_KEY] = h
			true
		end
		private :save!

		# synchronous (for the most part)
		def use(username, password)
			@data_loaded = true
			@user = username
			@pass = password
			@line = nil
			#@caller = nil
			@sms_allowed_sender = nil
			@call_history = nil
			@balance = nil
			begin
				@disable_save = true
				lines = self.lines
				if lines && lines.size == 1
					@line = lines.first
				end
				senders = self.sms_allowed_sender
				if senders && (s = senders.grep(/^00/)).size == 1
					@caller = s.first.sub(/^00/, '+')
				end
			rescue Object
			ensure
				@disable_save = false
			end
			save!
			OdorikAPIChangeCredsNotification.post_notification
		end

		def balance(force_reload = false, &b)
			return call_synchronized(:balance, force_reload) if b.nil?

			load!

			if @balance.nil? || force_reload
				@balance = nil
				pload = {user: @user, password: @pass, user_agent: CLIENT_ID}
				AFMotion::HTTP.get(get_server + 'balance', pload) do |resp|
					if resp.success?
						@balance = resp.body.strip
						save!
						b.call(@balance)
					else
						b.call(nil) # resp.error.localizedDescription
					end
				end
			else
				b.call(@balance)
			end
			self
		end

		def lines(force_reload = false, &b)
			return call_synchronized(:lines, force_reload) if b.nil?

			load!

			if @lines.nil? || force_reload
				@lines = nil
				pload = {user: @user, password: @pass, user_agent: CLIENT_ID}
				AFMotion::HTTP.get(get_server + 'lines', pload) do |resp|
					if resp.success?
						@lines = resp.body.strip.split(/,/)
						save!
						b.call(@lines)
					else
						b.call(nil) # resp.error.localizedDescription
					end
				end
			else
				b.call(@lines)
			end

			self
		end

		def sms_allowed_sender(force_reload = false, &b)
			return call_synchronized(:sms_allowed_sender, force_reload) if b.nil?

			load!

			if @sms_allowed_sender.nil? || force_reload
				@sms_allowed_sender = nil
				pload = {user: @user, password: @pass, user_agent: CLIENT_ID}
				AFMotion::HTTP.get(get_server + 'sms/allowed_sender', pload) do |resp|
					if resp.success?
						@sms_allowed_sender = resp.body.strip.split(/,/)
						save!
						b.call(@sms_allowed_sender)
					else
						b.call(nil) # resp.error.localizedDescription
					end
				end
			else
				b.call(@sms_allowed_sender)
			end

			self
		end

		def sms(sender, recipient, message, delayed = nil, &b)
			return call_synchronized(:sms, sender, recipient, message, delayed) if b.nil?

			load!

			# FIXME: implement

			self
		end

		def callback(from, to, line, time, &b)
			return call_synchronized(:callback, from, to, line, time) if b.nil?

			load!

			pload = {
				user: @user,
				password: @pass,
				user_agent: CLIENT_ID,
				caller: from,
				recipient: to,
			}
			pload[:line] = line if line && !line.empty?
			pload[:delayed] = time.to_s if time && time != 0
			AFMotion::HTTP.post(get_server + 'callback', pload) do |resp|
				if resp.success?
					p [:callback, :ok, resp.body] if Device.simulator?
					ok = resp.body[/^(callback_ordered|successfully_enqueued)/]
					b.call(ok ? nil : resp.body)
				else
					p [:callback, :fail, resp.error.localizedDescription] if Device.simulator?
					b.call(resp.error.localizedDescription)
				end
			end

			self
		end

		def calls(from, to, force_reload = false, options = {}, &b)
			return call_synchronized(:calls, from, to, force_reload, options) if b.nil?
			load!

			if @call_history.nil? || force_reload
				@call_history = nil
				pload = {
					user: @user,
					password: @pass,
					user_agent: CLIENT_ID,
					from: from.strftime('%Y-%m-%dT%H:%M:%S%z').sub(/00$/, ':00'),
					to: to.strftime('%Y-%m-%dT%H:%M:%S%z').sub(/00$/, ':00'),
					order: 'descending',
				}
				pload.merge!(options) # optional params
				AFMotion::JSON.get(get_server + 'calls.json', pload) do |resp|
					if resp.success?
						if resp.object.kind_of?(Hash) && resp.object["errors"]
							p [:calls, :error, resp.object["errors"]] if Device.simulator?
							b.call(resp.object["errors"].join(', '))
						else
							p [:calls, :ok] if Device.simulator?
							@call_history = resp.object
							b.call(@call_history)
						end
					else
						p [:calls, :fail, resp.error.localizedDescription] if Device.simulator?
						b.call(resp.error.localizedDescription)
					end
				end
			else
				b.call(@call_history)
			end

			self
		end
	end
end
