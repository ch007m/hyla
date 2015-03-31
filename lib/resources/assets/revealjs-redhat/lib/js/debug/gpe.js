/**************************************************************/
/* Module GPE
/**************************************************************/
var GPE = {
    prepareList: function () {
        $('#expList').find('li:has(ul)')
            .click(function (event) {
                if (this == event.target) {
                    $(this).toggleClass('expanded');
                    $(this).children('ul').toggle('medium');
                }
                return false;
            })
            .addClass('collapsed')
            .children('ul').hide();

        //Create the button funtionality
        $('#expandList')
            .unbind('click')
            .click(function () {
                $('.collapsed').addClass('expanded');
                $('.collapsed').children().show('medium');
            })

        $('#collapseList')
            .unbind('click')
            .click(function () {
                $('.collapsed').removeClass('expanded');
                $('.collapsed').children().hide('medium');
            })
    },

    popuplink: function(audio_file) {
        window.open(audio_file,
            'audio',
            'resizable=yes,status=no,location=no,toolbar=no,menubar=no,fullscreen=no,scrollbars=no,dependent=no,width=400,height=200');
        return false
    },

    /* Selection audioblock under a section tag and move it before the title */
    moveAudioBlock: function() {
        $('section').each(function () {
            var $this = $(this);
            var $audio = $this.find('.audioblock');
            var $audioHtml = $audio.html();
            if ($audioHtml != null) {
                $this.removeData($audioHtml);
                $audio.prependTo($this);
            }
        });
    }
};


/**************************************************************/
/* Functions to execute on loading of the document            */
/**************************************************************/
$(document).ready(function () {
    
    // Check expandable and collapsable lists
    GPE.prepareList();

    // Add click event for <a href where id=popuplink and audio-file
    $("a[id][audio-file]").click(function () {
        GPE.popuplink($(this).attr('audio-file'))
    });
    
    GPE.moveAudioBlock();

});   