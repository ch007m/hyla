/* Selection audioblock under a section tag and move it before the title */
var $sections = $('section');
$sections.each(function () {
    var $this = $(this);
    var $audio = $this.find('.audioblock');
    var $audioHtml = $audio.html();
    if ($audioHtml != null) {
        $this.removeData($audioHtml);
        $audio.prependTo($this);
    }
});