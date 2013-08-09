module FormotionGetRow
	# XXX: we don't have it formotion 1.3.1, yet
	def get_row(key)
		r = nil
		self.form.send(:each_row) { |row| r = row if row.key == key }
		r
	end
	private :get_row

end
