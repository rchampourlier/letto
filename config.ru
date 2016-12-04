# frozen_string_literal: true
require_relative "./config/boot.rb"
require "letto"
Letto.start(rack_builder: self)
