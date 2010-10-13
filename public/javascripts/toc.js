// Adds expandable tutorial descriptions to portal page

document.observe('dom:loaded', function() {
	// Only execute if #tutorialList exists (i.e. on portal page)
	if ($('tutorialList')) {
		// hide paragraphs and insert spans for expanded/collapsed icons
		$$('#tutorialList p, #tutorialList div.hide, #tutorialList ul').invoke('hide');
		$$('#tutorialList div.hide p').invoke('show');
		$$('#tutorialList li').invoke('insert', {top: '<span></span>'});
		
		// when span is clicked, toggle the span's expanded class and toggle the paragraph's display
		$$('#tutorialList span').invoke('observe', 'click', function() {
			this.toggleClassName('expanded');
			if (this.next('p')) {this.next('p').toggle();}		
			if (this.next('ul')) {this.next('ul').toggle();}
			if (this.next('div.hide')) {this.next('div.hide').toggle();}
		});
	};

});
