require 'j_chem_web_service'


#Lib options
$soap_lib=['savon', 'soap4r', 'handsoap']
$xml_lib=['REXML','LIBXML2','HPRICOT', 'JAXP']
#TODO, implementing handsoap and JAXP in future

#Example conversion
inputc = 'smiles'
outputp = 'png'
outputm = 'mol'
structure = 'C1CCCCC1'
outputf=JChemWebService.jconvert($soap_lib[1], structure, outputm)
puts outputf
outputi=JChemWebService.jconvert_special_input($soap_lib[1], structure, inputc, outputp)
puts outputi
#Get connection id
connection_id=JChemWebService.jget_connection($soap_lib[0])
puts connection_id

#Example search
searchtable='DrugBank'
searchquery = 'C1CCCCC1'
searchoptions=''
searchstart=0
searchcount=100
searchoutputformat= 'smiles'
searchfields='cd_id cd_formula cd_molweight'
searchconnection=connection_id

search_results=JChemWebService.jrun_complete_search($soap_lib[0], $xml_lib[2], searchconnection, searchtable, searchquery, searchoptions, searchstart, searchcount, searchoutputformat, searchfields)
if (search_results[0].length == search_results[1].length)
  for i in 0..(search_results[0].length-1)
    puts search_results[0][i], "\t", search_results[1][i], "\t", search_results[2][i], "\t", search_results[3][i]
  end
end


