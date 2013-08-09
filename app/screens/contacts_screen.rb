class ContactsScreen < ABPeoplePickerNavigationController
	include PM::ScreenModule

	tab_bar_item title: "Contacts"._, icon: "icons/111-user.png"

	def on_create(args)
		@cancel_cb = args[:cancel_cb]
		@close_on_cancel = args[:close_on_cancel]
		@person_select_cb = args[:person_select_cb]
		@phone_select_cb = args[:phone_select_cb]
		@close_after_select = args[:close_after_select]
		@keep_cancel = args[:keep_cancel]
		@show_properties = args[:show_properties] || [ KABPersonPhoneProperty ]
		@my_prompt = args[:prompt]

		super(args)
	end

	def will_appear
		self.peoplePickerDelegate = self
		self.delegate = self # FIXME: ok with PM?
		self.displayedProperties = @show_properties
	end


	def navigationController(navC, willShowViewController:viewController, animated:animated)
		viewController.navigationItem.setPrompt(@my_prompt) if @my_prompt
		unless @keep_cancel
			if (0..1).include?(navC.viewControllers.index(viewController))
				viewController.navigationItem.rightBarButtonItem = nil
			end
		end
	end

	def peoplePickerNavigationController(people_picker, shouldContinueAfterSelectingPerson:ab_person)
		# if we have a person select callback, call it and take it from there
		if @person_select_cb
			person = AddressBook::Person.new({}, ab_person)
			ret = @person_select_cb.call(person)
			if @close_after_select
				self.dismissModalViewControllerAnimated(true)
				false
			else
				ret
			end
		else
			true
		end

		# FIXME: handle single-phone case -> skip ahead to @phone_select_cb;
		# that way user won't have to click again.
	end

	def peoplePickerNavigationController(people_picker, shouldContinueAfterSelectingPerson:ab_person, property:property, identifier:id)
		if @phone_select_cb
			person = AddressBook::Person.new({}, ab_person)
			ret = @phone_select_cb.call(person, property, id)
			if @close_after_select
				self.dismissModalViewControllerAnimated(true)
				false
			else
				ret
			end
		else
			false
		end
	end

	def peoplePickerNavigationControllerDidCancel(people_picker)
		@cancel_cb.call() if @cancel_cb
		self.dismissModalViewControllerAnimated(true) if @close_on_cancel
	end

	# Required functions for ProMotion to work properly
	def self.new(args = {})
		s = self.alloc.initWithNibName(nil, bundle:nil) # Use your custom initializer if you want.
		s.on_create(args)
		s
	end

	def viewDidLoad
		super
		self.view_did_load if self.respond_to?(:view_did_load)
	end

	def viewWillAppear(animated)
		super
		self.view_will_appear(animated) if self.respond_to?("view_will_appear:")
	end

	def viewDidAppear(animated)
		super
		self.view_did_appear(animated) if self.respond_to?("view_did_appear:")
	end

	def viewWillDisappear(animated)
		self.view_will_disappear(animated) if self.respond_to?("view_will_disappear:")
		super
	end

	def viewDidDisappear(animated)
		self.view_did_disappear(animated) if self.respond_to?("view_did_disappear:")
		super
	end

	def shouldAutorotateToInterfaceOrientation(orientation)
		self.should_rotate(orientation)
	end

	def shouldAutorotate
		self.should_autorotate
	end

	def willRotateToInterfaceOrientation(orientation, duration:duration)
		self.will_rotate(orientation, duration)
	end

	def didRotateFromInterfaceOrientation(orientation)
		self.on_rotate
	end
end
