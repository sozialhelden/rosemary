require 'spec_helper'
include Rosemary

describe Hash do

    let(:symbolized_hash)  { Hash.new(a: :b) }
    let(:stringified_hash) { Hash.new("a" => :b) }
    let(:mixed_hash)       { Hash.new("a" => :b, :c => :d) }

    context 'stringify' do
      subject { symbolized_hash }

      it "turns symbol keys into strings" do
        expect(subject.stringify_keys!).to eql stringified_hash
      end

      it "makes sure all keys are strings" do
        mixed_hash.stringify_keys!
        mixed_hash.keys.each do |key|
          expect(key).to be_kind_of(String)
        end
      end
    end

    context 'symbolize' do
      subject { stringified_hash }

      it "turns string keys into symbols" do
        expect(subject.symbolize_keys!).to eql symbolized_hash
      end

      it "makes sure all keys are strings" do
        mixed_hash.symbolize_keys!
        mixed_hash.keys.each do |key|
          expect(key).to be_kind_of(Symbol)
        end
      end
    end
end
