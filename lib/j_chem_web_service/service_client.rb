require 'rubygems'
require 'soap/rpc/driver'
require 'savon'
require 'soap_xml_parser'

#Web service namespace
$ns_service='http://webservice.jchem.chemaxon'
#List of services
$jChemConnectionWS='http://localhost:8180/axis2/services/ConnectionWS'
$jChemSearchWS='http://localhost:8180/axis2/services/JChemSearchWS'
$jChemMolCon='http://localhost:8180/axis2/services/MolConvertWS'

#Information for database connection
$dbDriv='com.mysql.jdbc.Driver'
$dbUrl='jdbc:mysql://localhost:3306/chemdb'
$dbUsername='molseek'
$dbPassword='molseek2010'
$dbPropTable='JChemProperties'

module JChemWebService
    def JChemWebService.jget_connection(libtype)
      if libtype == 'soap4r'
        client_connection = SOAP::RPC::Driver.new($jChemConnectionWS+"?wsdl",$ns_service)
        client_connection.add_method('getConnection', 'driver', 'url', 'username', 'password', 'propertyTable')
        connection = client_connection.getConnection($dbDriv, $dbUrl, $dbUsername, $dbPassword, $dbPropTable)
        connection_code='connectionHandlerID-'+connection.scan(/\d+/).join
        return connection_code
      elsif libtype == 'savon'
        client_connection = Savon::Client.new $jChemConnectionWS
        connection=client_connection.get_connection! do |soap|
          soap.namespace = "http://webservice.jchem.chemaxon"
          soap.action = "getConnection"
          soap.input = "getConnection"
          soap.body = { :driver => $dbDriv, :url => $dbUrl, :username => $dbUsername, :password => $dbPassword, :propertyTable => $dbPropTable}
        end
        connection_code='connectionHandlerID-'+connection.to_hash[:get_connection_response][:return].scan(/\d+/).join
        return connection_code
      end
    end

    def JChemWebService.jrun_complete_search (slibtype, xlibtype, connection, table, query, options, start, count, outputformat, fields)
      if slibtype == 'soap4r'
        client_search = SOAP::RPC::Driver.new($jChemSearchWS+"?wsdl",$ns_service)
        client_search.add_method('runCompleteSearch','connectionHandlerId','tableName','queryMolecule','queryOptions','beginIndex', 'count', 'outputFormat', 'dataFieldNames')
        search_xml=client_search.runCompleteSearch(connection, table, query, options, start, count, outputformat,  fields)
        search_results=SoapXmlParser.search_parser(xlibtype, search_xml)
        return search_results
      elsif slibtype == 'savon'
        client_search =  Savon::Client.new $jChemSearchWS
        search_res=client_search.run_complete_search! do |soap|
          soap.namespace = $ns_service
          soap.action = "runCompleteSearch"
          soap.input = "runCompleteSearch"
          soap.body = { :connectionHandlerId => connection, :tableName => table, :queryMolecule => query, :queryOptions => options, :beginIndex => start, :count => count, :outputFormat => outputformat, :dataFieldNames => fields}
        end
        search_xml=search_res.to_hash[:run_complete_search_response][:return]
        search_results=SoapXmlParser.search_parser(xlibtype, search_xml)
        return search_results
      end
    end

    def JChemWebService.jconvert (slibtype, structure, outputformat)
      if slibtype == 'soap4r'
        client_convert = SOAP::RPC::Driver.new($jChemMolCon+"?wsdl",$ns_service)
        client_convert.add_method('convert', 'targetStructure', 'outputFormat')
        output=client_convert.convert(structure, outputformat)
        return output
      elsif slibtype == 'savon'
        client_convert =  Savon::Client.new $jChemMolCon
        output=client_convert.convert! do |soap|
          soap.namespace = $ns_service
          soap.action = "convert"
          soap.input = "convert"
          soap.body = { :targetStructure => structure, :outputFormat => outputformat}
        end
        return output.to_hash[:convert_response][:return]
      end
    end

    def JChemWebService.jconvert_special_input(slibtype, structure, inputformat, outputformat)
      if slibtype == 'soap4r'
        client_convert = SOAP::RPC::Driver.new($jChemMolCon+"?wsdl",$ns_service)
        client_convert.add_method('convertSpecialInput', 'targetStructure', 'inputFormat', 'outputFormat')
        output=client_convert.convertSpecialInput(structure, inputformat, outputformat)
        return output
      elsif slibtype == 'savon'
        client_convert =  Savon::Client.new $jChemMolCon
        output=client_convert.convert_special_input! do |soap|
          soap.namespace = $ns_service
          soap.action = "convertSpecialInput"
          soap.input = "convertSpecialInput"
          soap.body = { :targetStructure => structure, :inputFormat => inputformat, :outputFormat => outputformat}
        end
        return output.to_hash[:convert_special_input_response][:return]
      end
    end
end
