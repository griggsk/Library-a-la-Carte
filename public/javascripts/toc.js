// Adds hover effect to table of contents page, expandable effect to table of contents lists on unit/chapter/lesson pages, and expandable effect to portal page

document.observe('dom:loaded', function() {



// *** EXPANDABLE TOC LISTS

// Only execute if TOC doesn't have class "hover" (i.e. on unit/chapter/lesson pages)
if ($('toc') && !$('toc').hasClassName('hover')) {

    // hide all lists in TOC, but then unhide the current li's ancestors and immediate children
    $$('#toc ol').invoke('hide');
    $$('#toc .current > ol').invoke('show');
    $('toc').down('.current').ancestors().invoke('show');

    // insert spans for expanded/collapsed icons
    $$('#toc > li, #toc > li > ol > li').invoke('insert', {top: '<span></span>'});

    // add expanded class to expanded levels' spans
    $('toc').select('.current > span').invoke('addClassName', 'expanded');
    $('toc').down('.current').ancestors().each(function(element) {
        if (element.descendantOf('toc') && element.down('span')) {
            element.down('span').addClassName('expanded');
        };
    });

    // when span is clicked, toggle its expanded class and toggle the display of the adjacent ol
    $$('#toc span').invoke('observe', 'click', function() {
        this.toggleClassName('expanded');    
        this.next('ol').toggle();
    });
};



// *** EXPANDABLE LESSON DESCRIPTIONS

// Only execute if #tutorialList exists (i.e. on portal page)
if ($('tutorialList')) {

    // hide paragraphs and insert spans for expanded/collapsed icons
    $$('#tutorialList p').invoke('hide');
    $$('#tutorialList ul').invoke('hide');
    $$('#tutorialList li').invoke('insert', {top: '<span></span>'});
    
    // when span or paragraph is clicked, toggle the span's expanded class and toggle the paragraph's display
    $$('#tutorialList span').invoke('observe', 'click', function() {
        this.toggleClassName('expanded');    
        this.next('p').toggle();
        if (this.next('ul')) {
			this.next('ul').toggle();
		}
    });
    $$('#tutorialList p').invoke('observe', 'click', function() {
        this.previous('span').toggleClassName('expanded');    
        this.toggle();
    });
};

});
