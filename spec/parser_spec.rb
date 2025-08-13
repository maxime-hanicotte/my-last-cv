require 'spec_helper'
RSpec.describe MyLastCV::Parser do
  let(:md) do
    <<~MD
    # Maxime Hanicotte
    email: max_hanicotte@msn.com
    location: Annecy, France

    ## Expérience
    - Société A — Dev
    - Société B — Senior
    MD
  end

  it 'parse the name and contact' do
    parsed = described_class.new(md).parse
    expect(parsed[:name]).to eq('Maxime Hanicotte')
    expect(parsed[:contact]).to include('max_hanicotte@msn.com')
  end
end
