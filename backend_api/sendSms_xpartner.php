<?php
function sendSMSF($msg, $mobile, $nameMask, $campaignName, $refTb, $refName, $conn, $custom_mahalla_id = null)
{

    if ($custom_mahalla_id !== null) {
        $mahalla_id = (int)$custom_mahalla_id;
    } else {
        if (isset($_SESSION['role']) && $_SESSION['role'] === 'org_admin') {
            $mahalla_id = 0;
        } elseif (isset($_SESSION['mahalla_id'])) {
            $mahalla_id = (int)$_SESSION['mahalla_id'];
        } elseif (isset($_SESSION['pub_mahalla_id'])) {
            $mahalla_id = (int)$_SESSION['pub_mahalla_id'];
        } else {
            $mahalla_id = 0;
        }
    }

    $url = 'https://powersoftt.com/sms_request.php';
    
    
    $mobilesRaw = $mobile;
    
    $mobileArray = explode(",", $mobilesRaw);
    $normalizedMobiles = [];
    
    foreach ($mobileArray as $mob) {
        $mob = str_replace([' ', '-', ','], '', $mob);
        if ($mob === '') {
            continue;
        }
        if (strlen($mob) <= 10) {
            $mob = '94' . substr($mob, -9);
        }
        $normalizedMobiles[] = $mob;
    }
    
    $mobile = implode(',', $normalizedMobiles);

    $data = [
        'msg' => $msg,
        'phone' => $mobile,
        'nameMask' => $nameMask,
        'campaignName' => $campaignName
    ];

    $ch = curl_init($url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, http_build_query($data));

    $response = curl_exec($ch);

    if (curl_errno($ch)) {
        echo 'cURL error: ' . curl_error($ch);
    }
    
    $responseData = json_decode($response, TRUE);
    curl_close($ch);
    
    $rdate=date('Y-m-d'); $time = date('H:i:s');
	$smsResponse = $responseData['serverRef'];
	
	$messageCount = strlen($msg);
	$smsCount = $messageCount/160;
    $smsCount = ceil($smsCount);
    
    if(isset($responseData['serverRef'])){
        foreach ($mobileArray as $mob) {
            $smsAmnt = 1*$smsCount;
            
            $conn->query("UPDATE `sms_provider` SET `balance`= (`balance`-".$smsAmnt."),`tot_send`=(`tot_send`+1), `currnt_monSend`=(`currnt_monSend`+1) WHERE `apiKey`='$nameMask'");
            $message = $conn->real_escape_string($msg);
    
            $qry_smsRecord=$conn->query("INSERT INTO `sms_sendcount`(`serverRef`, `br_id`, `form_name`, `type`, `sms`, `mobile`, `provider`, `rdate`, `rtime`, `user_ID`,sms_format,cusID,`sms_count`, `mahalla_id`) VALUES
                                                                    ('$smsResponse', '1','$smsAmnt','$campaignName','$message','$mob','Etisalet', '$rdate','$time','1','$refName','$refTb','$smsCount', '$mahalla_id')");
        
        }        
    }else{
        foreach ($mobileArray as $mob) {
            $message = $conn->real_escape_string($msg);
            $qry_smsRecordError=$conn->query("INSERT INTO `sms_sendcount_error`(`serverRef`, `br_id`, `form_name`, `type`, `sms`, `mobile`, `provider`, `rdate`, `rtime`, `user_ID`,sms_format,cusID,`errors`,`sms_count`, `mahalla_id`) VALUES
                                                                                ('$smsResponse','1','$smsAmnt','$campaignName','$message','$mob','Etisalet', '$rdate','$time','1','$refName','$refTb','','$smsCount', '$mahalla_id')");
    
        }           
    }
    
    return $response;
}

// Message and other parameters for the SMS
// $message = "Dear Pilgrim, Reg No: 260000\n\nAlhamdhulillah, your pilgrimage for Hajj 2026 with Amnath Travels has been successfully confirmed.";
// $nameMask = "Hajj DMRCA";
// $campaignName = "HajjSrilanka25";

// $responses = sendSMSF($message, 94775656798, $nameMask, $campaignName);
// echo "SMS sent to " . 94775656798 . ": " . $responses . "<br>";
?>