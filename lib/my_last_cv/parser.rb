module MyLastCV
  class Parser
    def initialize(markdown)
      @markdown = markdown
    end

    def parse
      lignes = @markdown.lines.map(&:chomp)
      resultat = { sections: [] }
      section_actuelle = nil
      element_actuel  = nil

      lignes.each do |ligne|
        line = ligne
        next if line.strip.empty?

        if (m = line.match(/^#\s+(.*)/))
          resultat[:name] = m[1].strip
          section_actuelle = nil
          element_actuel   = nil

        elsif (m = line.match(/^(email|phone|location):\s*(.+)/i))
          (resultat[:contact] ||= []) << m[2].strip

        elsif (m = line.match(/^##\s+(.*)/))
          section_actuelle = { title: m[1].strip, items: [], elements: [] }
          resultat[:sections] << section_actuelle
          element_actuel = nil

        elsif (m = line.match(/^###\s+(.*)/))
          section_actuelle ||= { title: "Divers", items: [], elements: [] }
          resultat[:sections] << section_actuelle unless resultat[:sections].include?(section_actuelle)

          element_actuel = { title: m[1].strip, items: [] }
          section_actuelle[:elements] ||= []
          section_actuelle[:elements] << element_actuel

        elsif (m = line.match(/^[-*]\s+(.*)/))
          if element_actuel
            element_actuel[:items] << m[1].strip
          else
            section_actuelle ||= { title: "Divers", items: [], elements: [] }
            resultat[:sections] << section_actuelle unless resultat[:sections].include?(section_actuelle)
            section_actuelle[:items] << m[1].strip
          end
        else
          if element_actuel && !element_actuel[:items].empty?
            element_actuel[:items][-1] += " " + line.strip
          elsif section_actuelle && !section_actuelle[:items].empty?
            section_actuelle[:items][-1] += " " + line.strip
          else
            section_actuelle ||= { title: "Divers", items: [], elements: [] }
            section_actuelle[:items] << line.strip
          end
        end
      end

      resultat[:contact] = (resultat[:contact] || []).join(" · ")
      resultat
    end
  end
end
