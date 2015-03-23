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