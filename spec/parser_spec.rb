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

  it "manage elements in sections" do
    md = <<~MD
      # Jean
      email: j@example.com

      ## Expérience
      - Ligne de section

      ### Projets
      - A
      - B

      ### Récompenses
      - Prix X
    MD

    parsed = described_class.new(md).parse
    experience = parsed[:sections].find { |s| s[:title] == "Expérience" }
    expect(experience[:items]).to include("Ligne de section")
    expect(experience[:elements].map { |e| e[:title] }).to eq(["Projets", "Récompenses"])
    expect(experience[:elements].first[:items]).to eq(["A", "B"])
  end

end
