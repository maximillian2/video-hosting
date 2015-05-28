// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery2
//= require jquery_ujs
//= require bootstrap
//= require jquery.ui.accordion
//= require turbolinks
//= require_tree .

$(document).ready(function(){
    $('input[type=password][name=password_hint]').tooltip({ /*or use any other selector, class, ID*/
        placement: "right",
        trigger: "focus"
    });

    $('input[type=password][name=current_password_hint]').tooltip({ /*or use any other selector, class, ID*/
        placement: "right",
        trigger: "focus"
    });
});