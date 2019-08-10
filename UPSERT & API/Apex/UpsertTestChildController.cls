/*
UpsertTestChildController.execute();
*/

public with sharing class UpsertTestChildController {

    public static void execute(){
        List<TestParent1__c> tp1List = getTestParent1s();
        List<TestParent2__c> tp2List = getTestParent2s();
        upsertTestChild();
    }

    private static List<TestParent1__c> getTestParent1s(){
        List<TestParent1__c> tp1List = [Select Id, Name,
                                    ExtText1__c 
                                    from TestParent1__c
                                    where ExtText1__c != null];
        System.debug('tp1List size: ' + tp1List.size());
        Integer i=0;
        for(TestParent1__c tp1: tp1List){
            String strValue = '';
            strValue += 'Id: [' + tp1.Id + ']';
            strValue += ' Name: [' + tp1.Name + ']';
            strValue += ' ExtText1__c: [' + tp1.ExtText1__c + ']';
            System.debug(i + '[' + strValue + ']');
            i++;
        }
        return tp1List;
    }

    private static List<TestParent2__c> getTestParent2s(){
        List<TestParent2__c> tp2List = [Select Id, Name,
                                    ExtText2__c 
                                    from TestParent2__c
                                    where ExtText2__c != null];
        System.debug('tp2List size: ' + tp2List.size());
        Integer i=0;
        for(TestParent2__c tp2: tp2List){
            String strValue = '';
            strValue += 'Id: [' + tp2.Id + ']';
            strValue += ' Name: [' + tp2.Name + ']';
            strValue += ' ExtText2__c: [' + tp2.ExtText2__c + ']';
            System.debug(i + '[' + strValue + ']');
            i++;
        }
        return tp2List;
    }

    private static void upsertTestChild(){
        deleteTestChild();
        System.debug(' getTestChilds before');
        List<TestChild__c> cldList1 = getTestChilds();

        String extStrA = 'AAA';
        String extStrB = 'BBB';

        List<TestChild__c> cldList = new List<TestChild__c>();
        TestChild__c cld1 = new TestChild__c();
        cld1.ExtChild__c = 'cld1';
        cld1.TestParent1__r = new TestParent1__c(ExtText1__c = extStrA);
        cld1.TestParent2__r = new TestParent2__c(ExtText2__c = extStrA);
        cldList.add(cld1);

        TestChild__c cld2 = new TestChild__c();
        cld2.ExtChild__c = 'cld2';
        cld2.TestParent1__r = new TestParent1__c(ExtText1__c = extStrB);
        cld2.TestParent2__r = new TestParent2__c(ExtText2__c = extStrB);
        cldList.add(cld2);

        upsert cldList;

        System.debug(' getTestChilds after');
        List<TestChild__c> cldList2 = getTestChilds();
    }

    private static void deleteTestChild(){
        List<TestChild__c> cldList = [Select Id
                                    from TestChild__c];
        System.debug('delete cldList : ' + cldList.size());
        delete cldList;
    }

    private static List<TestChild__c> getTestChilds(){
        List<TestChild__c> cldList = [Select Id, Name,
                                    TestParent1__c,
                                    TestParent2__c 
                                    from TestChild__c];
        System.debug('cldList size: ' + cldList.size());
        Integer i=0;
        for(TestChild__c cld: cldList){
            String strValue = '';
            strValue += 'Id: [' + cld.Id + ']';
            strValue += ' Name: [' + cld.Name + ']';
            strValue += ' TestParent1__c: [' + cld.TestParent1__c + ']';
            strValue += ' TestParent2__c: [' + cld.TestParent2__c + ']';
            System.debug(i + '[' + strValue + ']');
            i++;
        }
        return cldList;
    }
}
/*
//dataloader upsert

外部キー: ExtChild__c

参照外部キー: TestParent1__r : ExtText1__c
            TestParent2__r : ExtText2__c

Mapping:
ExtChild     : ExtChild__c
TestParent1  : TestParent1__r:ExtText1__c
TestParent2  : TestParent2__r:ExtText2__c

//child.csv
ExtChild,TestParent1,TestParent2
cld1,AAA,AAA
cld2,BBB,BBB
cld3,,AAA
*/

/*
//BulkApi (Soap式) curlCommand
// \ option ¥
https://developer.salesforce.com/docs/atlas.en-us.api_asynch.meta/api_asynch/asynch_api_quickstart_requests_intro.htm
Loacle 環境
cd /mnt/c/Users/ryoichi.tachibana/curlTest

Step 1. login
curl https://login.salesforce.com/services/Soap/u/46.0 -H "Content-Type: text/xml; charset=UTF-8" -H "SOAPAction: login" -d @login.txt

<sessionId>00D2v0000013Xa7\!AQ0AQB34GD19M1rTgjzUiG7CKEpAI.pLE_KZ5EcIcF0NG2kr490qO.TPXntscVc0Wg.FLB0mxjAdMify7Mcc5ze1vd9Ya3v5</sessionId>

Step 2. Create a Job
curl https://curious-panda-vpcryr-dev-ed.my.salesforce.com/services/async/46.0/job -H "X-SFDC-Session: 00D2v0000013Xa7\!AQ0AQB34GD19M1rTgjzUiG7CKEpAI.pLE_KZ5EcIcF0NG2kr490qO.TPXntscVc0Wg.FLB0mxjAdMify7Mcc5ze1vd9Ya3v5" -H "Content-Type: application/xml; charset=UTF-8" -d @register_job.xml

-----------------------------------------
<id>7502v00000FAAdiAAH</id>

Step 3: Add a Batch to the Job
curl https://curious-panda-vpcryr-dev-ed.my.salesforce.com/services/async/46.0/job/7502v00000FAAdiAAH/batch -H "X-SFDC-Session: 00D2v0000013Xa7\!AQ0AQB34GD19M1rTgjzUiG7CKEpAI.pLE_KZ5EcIcF0NG2kr490qO.TPXntscVc0Wg.FLB0mxjAdMify7Mcc5ze1vd9Ya3v5" -H "Content-Type: text/csv; charset=UTF-8" --data-binary @TestChild.csv

----------------------------------
<id>7512v00000LbcO4AAJ</id>

Step 4: Check Batch Status
curl https://curious-panda-vpcryr-dev-ed.my.salesforce.com/services/async/46.0/job/7502v00000FAAdiAAH/batch/7512v00000LbcO4AAJ -H "X-SFDC-Session: 00D2v0000013Xa7\!AQ0AQB34GD19M1rTgjzUiG7CKEpAI.pLE_KZ5EcIcF0NG2kr490qO.TPXntscVc0Wg.FLB0mxjAdMify7Mcc5ze1vd9Ya3v5"

Step 5: Close the Job
curl https://curious-panda-vpcryr-dev-ed.my.salesforce.com/services/async/46.0/job/7502v00000FAAdiAAH -H "X-SFDC-Session: 00D2v0000013Xa7\!AQ0AQB34GD19M1rTgjzUiG7CKEpAI.pLE_KZ5EcIcF0NG2kr490qO.TPXntscVc0Wg.FLB0mxjAdMify7Mcc5ze1vd9Ya3v5" -H "Content-Type: application/xml; charset=UTF-8" -d @close_job.xml

Step 6: Retrieve Batch Results
curl https://curious-panda-vpcryr-dev-ed.my.salesforce.com/services/async/46.0/job/7502v00000FAAdiAAH/batch/7512v00000LbcO4AAJ/result -H "X-SFDC-Session: 00D2v0000013Xa7\!AQ0AQB34GD19M1rTgjzUiG7CKEpAI.pLE_KZ5EcIcF0NG2kr490qO.TPXntscVc0Wg.FLB0mxjAdMify7Mcc5ze1vd9Ya3v5"

//login.txt
<?xml version="1.0" encoding="utf-8" ?>
<env:Envelope xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">
  <env:Body>
    <n1:login xmlns:n1="urn:partner.soap.sforce.com">
      <n1:username>r.tachibana@curious-panda-vpcryr.com</n1:username>
      <n1:password>1qazxsw2YYP2uOBq98hS5F6JUfIwrSl78</n1:password>
    </n1:login>
  </env:Body>
</env:Envelope>

//register_job.xml
<?xml version="1.0" encoding="UTF-8"?>
<jobInfo xmlns="http://www.force.com/2009/06/asyncapi/dataload">
    <operation>upsert</operation>
    <object>TestChild__c</object>
    <externalIdFieldName>ExtChild__c</externalIdFieldName>
    <contentType>CSV</contentType>
</jobInfo>

//close_job.xml
<?xml version="1.0" encoding="UTF-8"?>
<jobInfo xmlns="http://www.force.com/2009/06/asyncapi/dataload">
    <state>Closed</state>
</jobInfo>

//data TestChild.csv
ExtChild__c,TestParent1__r.ExtText1__c,TestParent2__r.ExtText2__c
cld1,AAA,AAA
cld2,BBB,BBB

*/

/*
//workbeanch
① 1レコード RestApi 
https://trailhead.salesforce.com/ja/content/learn/modules/api_basics/api_basics_rest
https://developer.salesforce.com/docs/atlas.ja-jp.api_rest.meta/api_rest/dome_upsert.htm

/services/data/v45.0/sobjects/TestChild__c/ExtChild__c/cld1
Method: PATCH
ヘッダー: Content-Type: application/json; charset=UTF-8
        Accept: application/json
※ Jsonのみサポート Csvがサポートしない

JSON リクエストボディ 
{
    "TestParent1__r" :
    {
        "ExtText1__c" : "AAA"
    },
    "TestParent2__r" :
    {
        "ExtText2__c" : "AAA"
    }
}

② 複数レコード BulkApi
https://trailhead.salesforce.com/ja/content/learn/modules/api_basics/api_basics_bulk

1) ジョブを作成
/services/data/v45.0/jobs/ingest
Method: post
ヘッダー: Content-Type: application/json; charset=UTF-8
        Accept: application/json
{
  "operation" : "upsert",
  "object" : "TestChild__c",
  "externalIdFieldName": "ExtChild__c",
  "contentType" : "CSV",
  "lineEnding" : "CRLF"
}

-------------
id: 7502v00000FAE3yAAH

2) ジョブへのデータの追加
// /services/data/v45.0/jobs/ingest/jobID/batches
/services/data/v45.0/jobs/ingest/7502v00000FAE3yAAH/batches
Method: PUT
ヘッダー: Content-Type: text/csv
        Accept: application/json

ExtChild__c,TestParent1__r.ExtText1__c,TestParent2__r.ExtText2__c
cld1,AAA,AAA
cld2,BBB,BBB

3) ジョブの終了
/services/data/v45.0/jobs/ingest/7502v00000FAE3yAAH
Method: PATCH
ヘッダー: Content-Type: application/json; charset=UTF-8
        Accept: application/json
{
   "state" : "UploadComplete"
}

4) ジョブの状況の確認
// /services/data/vXX.0/jobs/ingest/jobID
/services/data/v45.0/jobs/ingest/7502v00000FAE3yAAH
Method: GET

5) ジョブ結果の取得
OK
// /services/data/vXX.0/jobs/ingest/jobID/successfulResults
/services/data/v45.0/jobs/ingest/7502v00000FAE3yAAH/successfulResults
Method: GET

NG
// /services/data/vXX.0/jobs/ingest/jobID/failedResults
/services/data/v45.0/jobs/ingest/7502v00000FAE3yAAH/failedResults
Method: GET

*/