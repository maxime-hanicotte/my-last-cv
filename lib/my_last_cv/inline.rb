require 'cgi'

module MyLastCV
  class Inline
    LINK_COLOR = '0563C1'.freeze
    ESCAPABLE_CHARACTERS = "\\`*[]()".chars.freeze

    def self.parse(text)
      new(text).parse
    end

    def initialize(text)
      @text = text.to_s
      @index = 0
    end

    def parse
      parse_until(nil).first
    end

    private

    def parse_until(stop_token)
      output = +""

      while @index < @text.length
        if stop_token && token?(stop_token)
          @index += stop_token.length
          return [output, true]
        end

        output << if escaped_character?
                    consume_escaped_character
                  elsif token?('**')
                    parse_emphasis('**', 'b')
                  elsif token?('*')
                    parse_emphasis('*', 'i')
                  elsif token?('`')
                    parse_code
                  elsif token?('[')
                    parse_link
                  else
                    consume_plain_character
                  end
      end

      [output, false]
    end

    def escaped_character?
      current_character == '\\' && ESCAPABLE_CHARACTERS.include?(next_character)
    end

    def consume_escaped_character
      character = next_character
      @index += 2
      CGI.escapeHTML(character)
    end

    def consume_plain_character
      character = current_character
      @index += 1
      CGI.escapeHTML(character)
    end

    def parse_emphasis(delimiter, tag)
      start_index = @index
      @index += delimiter.length
      content, closed = parse_until(delimiter)

      return "<#{tag}>#{content}</#{tag}>" if closed && !content.empty?

      CGI.escapeHTML(@text[start_index...@index])
    end

    def parse_code
      start_index = @index
      @index += 1
      content = +""

      while @index < @text.length && !token?('`')
        content << @text[@index]
        @index += 1
      end

      return CGI.escapeHTML(@text[start_index...@index]) if @index >= @text.length

      @index += 1
      "<font name=\"Courier\">#{CGI.escapeHTML(content)}</font>"
    end

    def parse_link
      start_index = @index
      @index += 1
      label, closed = parse_until(']')
      return CGI.escapeHTML(@text[start_index...@index]) unless closed
      return CGI.escapeHTML(@text[start_index...@index]) unless token?('(')

      @index += 1
      url_start = @index
      @index += 1 while @index < @text.length && !token?(')')
      return CGI.escapeHTML(@text[start_index...@index]) if @index >= @text.length

      url = @text[url_start...@index]
      @index += 1
      return CGI.escapeHTML(@text[start_index...@index]) if url.strip.empty?

      %(<color rgb="#{LINK_COLOR}"><u><link href="#{CGI.escapeHTML(url)}">#{label}</link></u></color>)
    end

    def token?(value)
      @text[@index, value.length] == value
    end

    def current_character
      @text[@index]
    end

    def next_character
      @text[@index + 1]
    end
  end
end
