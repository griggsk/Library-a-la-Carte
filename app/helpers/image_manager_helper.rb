module ImageManagerHelper
  def  js_to_be_included
   %{
  <script language="JavaScript" type="text/javascript">
  <!--
  function Change_Value(val,id){
    var tar=document.getElementById(id);
    tar.value = val;
  }
  function Get_Change_Value(org_id,id){
    var tar=document.getElementById(id);
    var org_tar=document.getElementById(org_id);
    tar.value = org_tar.value;
  }
  function retrieve_values(){
    Get_Change_Value('alt','norm_desc');
    Get_Change_Value('title','norm_title');
  }
  function changeHeight(id,num){
    var tar=document.getElementById(id); 
    tar.style.height = parseInt(num);
  }
   function disableUpload(){
          document.getElementById('upload_button').disabled = true;
        }
  //-->
  </script>
    }
end

end
