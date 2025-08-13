module MyLastCV
  class Parser
    def initialize(markdown)
      @markdown = markdown
    end

    def parse
      lignes = @markdown.lines.map(&:chomp)
      resultat = { sections: [] }
      section_actuelle = nil

      lignes.each do |ligne|
        next if ligne.strip.empty?
        if (m = ligne.match(/^#\s+(.*)/))
          resultat[:name] = m[1].strip
        elsif (m = ligne.match(/^(email|phone|location):\s*(.+)/i))
          resultat[:contact] ||= []
          resultat[:contact] << m[2].strip
        elsif (m = ligne.match(/^##\s+(.*)/))
          section_actuelle = { title: m[1].strip, items: [] }
          resultat[:sections] << section_actuelle
        elsif (m = ligne.match(/^[-*]\s+(.*)/))
          section_actuelle ||= { title: "Divers", items: [] }
          resultat[:sections] << section_actuelle unless resultat[:sections].include?(section_actuelle)
          section_actuelle[:items] << m[1].strip
        end
      end

      resultat[:contact] = (resultat[:contact] || []).join(" · ")
      resultat
    end
  end
end
