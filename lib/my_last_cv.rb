require_relative 'my_last_cv/version'
require_relative 'my_last_cv/parser'
require_relative 'my_last_cv/style'
require_relative 'my_last_cv/renderer'

module MyLastCV
  def self.generate(input_path, output_path, style: Style.new)
    md = File.read(input_path)
    parsed = Parser.new(md).parse
    Renderer.new(parsed, style: style).to_pdf(output_path)
  end
end
