require 'webmock/rspec'
require 'rosemary'

require 'libxml'

RSpec::Matchers.define :have_xml do |xpath, text|
  match do |body|
    parser = LibXML::XML::Parser.string body
    doc = parser.parse
    nodes = doc.find(xpath)
    nodes.empty?.should be_false
    if text
      nodes.each do |node|
        node.content.should == text
      end
    end
    true
  end

  failure_message_for_should do |body|
    "expected to find xml tag #{xpath} in:\n#{body}"
  end

  failure_message_for_should_not do |response|
    "expected not to find xml tag #{xpath} in:\n#{body}"
  end

  description do
    "have xml tag #{xpath}"
  end
end