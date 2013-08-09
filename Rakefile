# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/ios'
require 'bundler'
Bundler.require
require 'sugarcube-gestures'
require 'sugarcube-notifications'
require 'sugarcube-color'
require 'sugarcube-nsdate'
require 'sugarcube-timer' # need for Fixnum#days, ha! (no need for this after issues #93 and #94 are resolved)
require 'sugarcube-localized'

# =============================================================================
# Assets support
# =============================================================================
if Dir["resources/icons/*.png"].size < 8
	STDERR.puts "=" * 78
	STDERR.puts "WARNING: Icons missing."
	STDERR.puts
	STDERR.puts "If you have a Glyphish3 Pro license, please add the needed " +
		"icons into resources/icons/, you can find the names in " + 
		"resources_enc/icons/ directory."
	STDERR.puts "If you don't have a license, you'll either have to go " +
		"without these assets (hard) or replace them with your own."
	STDERR.puts "=" * 78
	sleep 3
end

# =============================================================================
# Config file support
# =============================================================================
PROJECT_CONFIG_FILE = "config.yaml"

def set_vars(obj, hash)
	for k, v in hash
		if v.kind_of?(Hash)
			set_vars(obj.send(k), v)
		else
			obj.send "#{k}=", v
		end
	end
end

def load_config(app)
	config = YAML::load( File.open(PROJECT_CONFIG_FILE) )
	for mode in config.keys
		app.send(mode) do
			set_vars(app, config[mode])
		end
	end
rescue Object
	STDERR.puts "No config file!\n" +
		"Create #{PROJECT_CONFIG_FILE} if you want to override defaults."
end


# =============================================================================
# Main app setup
# =============================================================================
Motion::Project::App.setup do |app|
	load_config(app)

	app.name = 'Odorik'
	app.identifier = 'com.wejn.Odorik'
	app.info_plist['X_ITUNES_APP_ID'] = 682721789
	app.info_plist['X_ITUNES_IN_APPS'] = %w[milk 2cappu bag]
	app.version = app.short_version = "1.0"
	app.deployment_target = "6.0"
	app.sdk_version = "6.1"

	# certs/prov profiles setup in config.yaml

	app.icons += ['Icon', 'Icon-72', 'Icon-Small', 'Icon-Small-50']
	app.prerendered_icon = true

	app.frameworks << 'QuartzCore'
	app.frameworks << 'CFNetwork'
	app.frameworks << 'StoreKit'

	app.testflight.sdk = 'vendor/TestFlight'
	# the rest of TF is setup in config.yaml

	app.pods do
		pod 'AFNetworking'
		pod 'SVProgressHUD'
	end
end
