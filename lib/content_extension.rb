require File.join(RAILS_ROOT, 'app/models/content.rb')

class Content < ActiveRecord::Base
  acts_as_ferret :fields => [:body_html, :excerpt_html]
end
