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
    expect(parsed[:title]).to eq('Maxime Hanicotte')
    expect(parsed[:contact]).to include('max_hanicotte@msn.com')

    experience = parsed[:sections].find { |s| s[:title] == 'Expérience' }
    expect(experience).not_to be_nil
    expect(experience[:items]).to include(
      {text: "Société A — Dev", type: :bullet},
      {text: "Société B — Senior", type: :bullet}
    )
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
    expect(experience[:items]).to include({text: "Ligne de section", type: :bullet})
    expect(experience[:elements].map { |e| e[:title] }).to eq(["Projets", "Récompenses"])
    expect(experience[:elements].first[:items]).to eq([{text: "A", type: :bullet}, {text: "B", type: :bullet}])
  end

  it "attache correctement les paragraphes libres et les distingue des puces" do
    md = <<~MD
      # Jean
      email: j@example.com

      ## Expérience

      ### Projet X
      Paragraphe introductif libre du projet.
      - Développement de la gem
      - Mise en production

      ## Compétences
      - Ruby
    MD

    parsed = MyLastCV::Parser.new(md).parse
    exp = parsed[:sections].find { |s| s[:title] == "Expérience" }
    proj = exp[:elements].find { |e| e[:title] == "Projet X" }

    expect(exp[:items]).to eq([])
    expect(proj[:items].first).to eq(type: :paragraph, text: "Paragraphe introductif libre du projet.")
    expect(proj[:items][1]).to eq(type: :bullet, text: "Développement de la gem")
    expect(proj[:items][2]).to eq(type: :bullet, text: "Mise en production")
  end
end
