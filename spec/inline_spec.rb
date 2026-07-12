require 'spec_helper'

RSpec.describe MyLastCV::Inline do
  it 'converts bold, italic, links, and code to Prawn inline markup' do
    parsed = described_class.parse('Texte **gras**, *italique*, [lien](https://example.com) et `code`.')

    expect(parsed).to eq(
      'Texte <b>gras</b>, <i>italique</i>, <color rgb="0563C1"><u><link href="https://example.com">lien</link></u></color> et <font name="Courier">code</font>.'
    )
  end

  it 'supports nested formatting inside emphasis and links' do
    parsed = described_class.parse('**texte et *accent*** puis [**profil**](https://example.com)')

    expect(parsed).to eq(
      '<b>texte et <i>accent</i></b> puis <color rgb="0563C1"><u><link href="https://example.com"><b>profil</b></link></u></color>'
    )
  end

  it 'keeps escaped markdown characters literal' do
    parsed = described_class.parse('\*pas italique\* \[texte\] \`code\` \\')

    expect(parsed).to eq("*pas italique* [texte] `code` \\")
  end

  it 'keeps empty or unclosed emphasis literal' do
    parsed = described_class.parse('**** and **broken')

    expect(parsed).to eq('**** and **broken')
  end
end
