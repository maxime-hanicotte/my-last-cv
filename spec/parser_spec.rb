require 'spec_helper'
RSpec.describe MyLastCV::Parser do
  let(:md) do
    <<~MD
    # Maxime Hanicotte
    email: max_hanicotte@msn.com
    phone: 06 12 34 56 78
    location: Annecy, France

    ## Expérience
    - Société A — Dev
    - Société B — Senior
    MD
  end

  it 'parses the name, contact, and sections' do
    parsed = described_class.new(md).parse
    expect(parsed[:name]).to eq('Maxime Hanicotte')
    expect(parsed[:contact]).to include('max_hanicotte@msn.com')

    experience = parsed[:sections].find { |s| s[:title] == 'Expérience' }
    expect(experience).not_to be_nil
    expect(experience[:items]).to include('Société A — Dev', 'Société B — Senior')
  end
end
