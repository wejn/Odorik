class Favorite
	PERSISTENCE_KEY = 'favorites'
	def self.all
		@all ||= load || []
		if Device.simulator?
			@all = [
				Favorite.new(name: "John Snow"),
				Favorite.new(name: "John Doe"),
				Favorite.new(name: "Jake Drake"),
			] if @all.empty?
		end
		@all
	end

	def self.load
		favorites = App::Persistence[PERSISTENCE_KEY]
		return nil unless favorites
		favorites.map { |fave| Favorite.new(fave) }
	end

	def self.save!
		@queue ||= Dispatch::Queue.concurrent('com.wejn.Odorik.FaveSave')
		@queue.async do
			faves = all.map(&:serialize)
			App::Persistence[PERSISTENCE_KEY] = faves
		end
	end

	def self.add(fave)
		self.all << fave
		FavoritesReloadNotification.post_notification
	end

	def self.add!(fave)
		add(fave)
		save!
	end

	def self.from_ab(person, id)
		return nil if person.nil?
		name = nil
		if person.organization?
		   name = person.organization
		else
			attrs = [:first_name, :middle_name, :last_name, :suffix]
			attrs.unshift(:prefix) if AddressBook::Person.attribute_map[:prefix]
			name = attrs.map { |x| person.send(x) }.delete_if(&:nil?).join(" ")
		end

		phone = label = nil
		begin
			rec = person.phones.attributes[id]
			phone = rec[:value]
			label = rec[:label]
		rescue Object
			return nil
		end

		self.new(name: name, uid: person.uid, phone: phone, label: label)
	end

	def self.add_from_ab!(person, id)
		fave = from_ab(person, id)
		if fave.nil?
			false
		else
			add!(fave)
			true
		end
	end

	def serialize
		h = {
			name: @name,
			phone: @phone,
			label: @label || "default"._,
		}
		h[:uid] = @uid if @uid
		h
	end

	def to_cell(action = :tapped_item)
		{
			cell_style: UITableViewCellStyleSubtitle,
			cell_identifier: "FavoriteCell",
			cell_class: PM::TableViewCell,
			title: @name || "??",
			subtitle: @label || "default"._,
			image: { image: photo },
			# XXX: don't use straight "image: photo"
			# because ProMotion will reuse cell and keep the
			# old image set. Ouch.
			editing_style: :delete,
			action: action,
			arguments: self
		}
	end

	def initialize(opts = {})
		@name = opts[:name]
		@uid = opts[:uid] || nil
		@phone = opts[:phone] || '+420 555 555 555'
		@label = opts[:label] || 'default'._
		# FIXME: refresh by uid?
	end
	attr_accessor :name, :uid, :phone, :label

	def photo
		if (_photo = @photo)
			_photo
		else
			return nil unless @uid
			begin
				_pe = ABAddressBookGetPersonWithRecordID(
					AddressBook.address_book, @uid)
				if ABPersonHasImageData(_pe)
					_id = ABPersonCopyImageDataWithFormat(_pe,
						KABPersonImageFormatThumbnail)
					# XXX: copying the whole image wasn't working for some
					# contacts. I believe it was because of oversized images.
					_photo = UIImage.imageWithData(_id) unless _id.nil?
				else
					_photo = UIImage.imageNamed('missing-picture')
				end
			rescue Object
			end
			@photo = _photo
		end
		_photo
	end


	def self.move(from, to)
		return false if from == to
		begin
			item = @all.delete_at(from)
			@all[to, 0] = item
			save!
			FavoritesReloadNotification.post_notification
			true
		rescue Object
			false
		end
	end

	# delete at index & force reload
	def self.delete_at(idx)
		begin
			@all.delete_at(idx)
			save!
			FavoritesReloadNotification.post_notification
			true
		rescue Object
			false
		end
	end

	def self.delete(fave)
		begin
			idx = @all.index(fave)
			if idx
				@all.delete_at(idx)
				save!
				true
			else
				false
			end
		rescue Object
			false
		end
	end
end
