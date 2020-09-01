<cmpScript>
	<![CDATA[
        MainForm.addEvent('oncreate', function () {
            if (getVar('DIR_SERV_ID')== 0){
                setVar('DIR_SERV_ID', getVar('REP_ID'));
            }
            beginRequest();
            refreshDataSet('DsReport');
            refreshDataSet('DsPatientInfo');
            endRequest();
        });
        Form.directionServices = [];
        Form.showBarcode = function(DOM, source) {
            try {
                if (Form.canvas === undefined) {
                    Form.canvas = document.createElement('canvas');
                }
                var canvas = Form.canvas,
                    img = new Image();
                img.onload = function() {
                    var ctx = canvas.getContext('2d');
                    canvas.width = img.width;
                    canvas.height = img.height - 60;
                    ctx.clearRect(0, -60, canvas.width, canvas.height - 60);
                    ctx.drawImage(img, 0, -60, img.width, img.height);
                    DOM.src = canvas.toDataURL('image/png');
                    setVisible(DOM, true);
                };
                img.src = source;
            } catch(e) {
                console.log(e.name, e.message);
            }
        };
        Form.getBarcodes = function(clone, data) {
            setVar('PATIENT_ID', Form.directionServices.join(';'));
            executeAction('getBarcodes', function() {
                var barcodesList = JSON.parse(getVar('barcode_images'));
                for (var barcodeId in barcodesList) {
                    var image = document.querySelector('[id="barcode' + barcodeId + '"]');
                    if (image !== null) {
                        Form.showBarcode(image, barcodesList[barcodeId]);
                    }
                }
            });
        };
        Form.prepareBarcodeData = function(clone, data) {
            Form.directionServices.push(data['PATIENT_ID']);
            clone.querySelector('img').id = 'barcode' + data['PATIENT_ID'];
        };
      ]]>
</cmpScript>