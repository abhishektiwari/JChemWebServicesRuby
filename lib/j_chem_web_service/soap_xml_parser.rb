require 'rexml/document'
require 'libxml'
require 'hpricot'

include REXML
include LibXML
include Hpricot
module SoapXmlParser
    def SoapXmlParser.search_parser(xlibtype, xmlstring)
      if xlibtype == 'REXML'
        document = REXML::Document.new(xmlstring)
        #document.elements.each("Complete/Rows/Row/Molecule"){ |e| puts "Molecules : " + e.text }
        #document.elements.each("Complete/Rows/Row/cd_id"){ |e| puts "ID : " + e.text }
        mols = REXML::XPath.match(document, "//Molecule").map {|x| x.text }
        ids = REXML::XPath.match(document, "//cd_id").map {|x| x.text }
        formula = REXML::XPath.match(document, "//cd_formula").map {|x| x.text }
        molweight = REXML::XPath.match(document, "//cd_molweight").map {|x| x.text }
        return ids, mols, formula, molweight
      elsif xlibtype == 'LIBXML2'
        parser = LibXML::XML::Parser.new
        parser.string = xmlstring
        document = parser.parse
        document = LibXML::XML::Parser.string(xmlstring).parse
        mols = document.find('//Molecule').map {|x| x.content }
        ids = document.find('//cd_id').map {|x| x.content }
        formula = document.find('//cd_formula').map {|x| x.content }
        molweight = document.find('//cd_molweight').map {|x| x.content }
        return ids, mols, formula, molweight
      elsif xlibtype == 'HPRICOT'
         document = Hpricot::XML(xmlstring)
         mols=(document/"Molecule").map {|x| x.inner_html}
         ids=(document/"cd_id").map {|x| x.inner_html}
         formula=(document/"cd_formula").map {|x| x.inner_html}
         molweight=(document/"cd_molweight").map {|x| x.inner_html}
         return ids, mols, formula, molweight
      end
    end
end
