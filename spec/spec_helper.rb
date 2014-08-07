require 'webmock/rspec'
require 'rosemary'
require 'libxml'
require 'coveralls'
Coveralls.wear!

RSpec::Matchers.define :have_xml do |xpath, text|
  match do |body|
    parser = LibXML::XML::Parser.string body
    doc = parser.parse
    nodes = doc.find(xpath)
    expect(nodes).not_to be_empty
    if text
      nodes.each do |node|
        node.content.should == text
      end
    end
    true
  end

  failure_message do |body|
    "expected to find xml tag #{xpath} in:\n#{body}"
  end

  failure_message_when_negated do |response|
    "expected not to find xml tag #{xpath} in:\n#{body}"
  end

  description do
    "have xml tag #{xpath}"
  end
end