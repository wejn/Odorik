class RewardAuthorScreen < PM::GroupedTableScreen
	include PMSectionFooters

	title "Reward author"._

	def on_load
		SupporterDonatedNotification.add_observer(self, :supporter_refresh)
	end

	def supporter_refresh
		Dispatch::Queue.main.sync do
			@_table_data = nil
			update_table_data
		end
	end

	def on_appear
		fetch_table_data
	end

	def on_return(options = {})
		fetch_table_data
	end

	def title_for(product, price_usd)
		prefix = "Reward author with"._
		if @inapp_info && (info = @inapp_info[product.to_s])
			return [prefix, info[:price_str]].join(' ') if info[:price_str]
		end
		[prefix, "$#{price_usd}"].join(' ')
	end

	def table_data
		# from cache
		_td = @_table_data
		return _td unless _td.nil?
		_td = []
		if Supporter.is?
			subtitle = if Supporter.multi?
				"I can't thank you enough."._ + " \u2014 M.J."
			else
				"I highly appreciate it."._ + " \u2014 M.J."
			end
			_td << {
				cells: [{
					cell_identifier: "SupporterCell",
					cell_style: UITableViewCellStyleSubtitle,
					image: TintedImage.imageWithTint('icons/29-heart', "#990000".uicolor),
					title: "Thank you for your support!"._,
					subtitle: subtitle,
				}],
			}
		end
		_td += [{
			cells: [],
			footer: "If you find this app useful and want to reward its author for the hard work, you can reward him with cash equivalent of any of the following items.\n"._.gsub(/\&nbsp;/, " "),
		}, {
			title: "One liter of milk"._,
			cells: [{
				cell_identifier: "RewardCell",
				title: title_for("milk", "0.99"),
				action: :buy,
				arguments: "milk",
			}],
		}, {
			title: "Two cups of cappuccino"._,
			cells: [{
				cell_identifier: "RewardCell",
				title: title_for("2cappu", "4.99"),
				action: :buy,
				arguments: "2cappu",
			}],
		}, {
			title: "One 350g bag of coffee beans"._,
			cells: [{
				cell_identifier: "RewardCell",
				title: title_for("bag", "16.99"),
				action: :buy,
				arguments: "bag",
			}],
		}, {
			cells: [],
			footer: "Please note: These in-app purchases are entirely optional and will not unlock any additional features. It will give you a warm feeling that you supported development of this app, though."._.gsub(/\&nbsp;/, " "),
		}]
		@_table_data = _td
	end

	def buy(what)
		helu = Helu.new(what)
		ivn = ("@helu_" + what + "_" + Time.now.to_f.to_s.sub(/\./, '')).to_sym
		helu.fail = ->(transaction) {
			#p transaction
			#p transaction.error
			App.alert("Failed to purchase"._, { message: "Failed to process in-app purchase"._ })
			instance_variable_get(ivn).close
			instance_variable_set(ivn, nil)
		}
		helu.winning = ->(transaction) {
			#p transaction
			Supporter.set
			instance_variable_get(ivn).close
			instance_variable_set(ivn, nil)
		}
		instance_variable_set(ivn, helu) # hello RubyMotion GC
		helu.buy
	end

	def fetch_table_data
		Dispatch::Queue.concurrent.async do
			if inapps = NSBundle.mainBundle.infoDictionary['X_ITUNES_IN_APPS']
				inapp_info = AppStoreProductInfoFetcher.fetch(inapps)
				Dispatch::Queue.main.sync do
					@inapp_info = inapp_info
					@_table_data = nil
					update_table_data
				end
			end
		end
	end
end
