require 'rubygems'
require 'RedCloth'
require 'active_support' # to get methods like blank? and starts_with?
require 'action_view'  
require File.dirname(__FILE__) + '/../lib/textile_helpers'

include TextileHelpers::PublicMethods
include ActionView::Helpers::TextHelper
include ActionView::Helpers::TagHelper

describe TextileHelpers do
  
  context "textilize_plus" do
    it "returns nil when passed something other than a string" do
      textilize_plus().should be_nil
      textilize_plus(1).should be_nil
    end
    
    it "returns textilized text with a paragraph tag" do
      textilize_plus("test *string* _with_ markup").should == "<div class=\"textilized\"><p>test <strong>string</strong> <em>with</em> markup</p></div>"
    end

    it "returns textilized text without paragraph tag" do
      textilize_plus("*no* paragraph", :paragraph => false, :wrap_in_div => false).should == "<strong>no</strong> paragraph"
    end
  end
  
  context "add_id_attribute_to_textile_headings" do
    it "adds id attributes" do
      add_id_attribute_to_textile_headings("h1. Hello World").should == "h1(#hello-world). Hello World"      
      s = File.read(File.dirname(__FILE__) + "/sample_textile_string.txt")
      add_id_attribute_to_textile_headings(s).should include("h1(#good-one). Good One!")
    end
  end
  
  context "repair_faulty_textile_heading_markup" do
    it "adds newlines where needed" do
      s = File.read(File.dirname(__FILE__) + "/sample_textile_string.txt")
      s.split("\n").size.should == 11
      s.split("\n")[2].should == "h1. Head 123? Dada"
      s.split("\n")[3].should == "That was a bad h1 tag."

      new_string = repair_faulty_textile_heading_markup(s)
      new_string.split("\n").size.should == 13
      new_string.split("\n")[2].should == "h1. Head 123? Dada"
      new_string.split("\n")[3].should == ""
    end
  end
  
  context "replace_wonky_characters_with_ascii" do
    it "handles smart quotes" do
      replace_wonky_characters_with_ascii("\“Ulysses\”").should == "\"Ulysses\""
      replace_wonky_characters_with_ascii("And then…").should == "And then..."
      replace_wonky_characters_with_ascii("We ‘are’ single").should == "We 'are' single"
      replace_wonky_characters_with_ascii("We “are” double").should == "We \"are\" double"
    end
  end
  
  context "table_of_contents_for" do
    it "returns nil if no heading tags are found" do
      table_of_contents_for("no headings here").should be_nil
    end
    
    # it "returns" do
    #   
    # end
  end
  
  context "permalinkify" do
    it "permalinkifies" do
      permalinkify(" Bobby Sue ! Say Who?").should == "bobby-sue-say-who"
    end
  end

end