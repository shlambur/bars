<cmpAction name="getBarcodes" query_type="server_php">
	<![CDATA[
            D3Api::includeCode('Zint');
            $barcodes = array();
            foreach (explode(';', $vars['barcode_data']) as $barcode_data) {
                $barcodes[$barcode_data] = Zint::barcode($vars['barcode'], $barcode_data)->getImage();
            }
            $vars['barcode_images'] = json_encode((object)$barcodes);
        ]]>
	<cmpActionVar name="barcode"        src="20"             srctype="const"/>
	<cmpActionVar name="barcode_data"   src="DIR_SERV_IDS"   srctype="var"/>
	<cmpActionVar name="barcode_images" src="barcode_images" srctype="var" put=""/>
</cmpAction>