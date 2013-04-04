
// ---------------------------------------
// DOM ready set up
// ---------------------------------------
$(function(){

  $('#click').live('click',function(e){
    e.preventDefault();
    check_for_login();

  });

});

// ---------------------------------------
// Application AJAX calls
// ---------------------------------------


function create_entry(entry){
  $.post("/entries/new", { name: entry.name, fb_id: entry.id, locale: entry.locale, email: entry.email },
    function(data) {
      // console.log(data.message);
      $('#click').hide();
  });
}

// ---------------------------------------
// DOM manipulation Functions
// ---------------------------------------


// ---------------------------------------
// Facebook API calls
// ---------------------------------------

function check_for_login(){
  FB.getLoginStatus(function(response) {
    if (response.authResponse) {
      FB.api('/me', function(user) {
        create_entry(user);
      });
    } else {
      login();
    }
  });
}

function login(){
   FB.login(function(response) {
     if (response.authResponse) {
      FB.api('/me', function(user) {
        create_entry(user)
      });
     } else {
       console.log('User cancelled login or did not fully authorize.');
     }
  }, {scope: 'email'});
}

function resizeMyWindow(){
  FB.Canvas.setSize({height: $('#wrapper').height()});
}

function share(name, body) {

  var share_content = {
    method: 'feed',
    link: fb_page,
    picture: '',
    name: '',
    caption: name,
    description: body
  };

  function callback(response) {
    // console.log(response)
  }

  FB.ui(share_content, callback);
}
