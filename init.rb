require 'redmine'
require File.join(File.dirname(__FILE__), "lib", "awesome_nested_set_patch") 

Redmine::Plugin.register :redmine_tree_buster do
  name 'Redmine Tree Buster plugin'
  author 'Allan Davis'
  description 'Plugin to fix nested set and rebuild tree structure'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'
end
