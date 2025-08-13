require 'spec_helper'
RSpec.describe MyLastCV::Style do
  it 'as default values' do
    s = described_class.new
    expect(s.header_size).to be > 0
  end
end
