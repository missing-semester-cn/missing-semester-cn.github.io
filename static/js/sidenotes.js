(function() {
  'use strict';
  var content = document.getElementById('content');
  if (!content) return;

  var blockquotes = content.querySelectorAll('blockquote');
  if (blockquotes.length === 0) return;

  // Create sidenote column container
  var sidenoteColumn = document.createElement('div');
  sidenoteColumn.className = 'sidenote-column';
  content.appendChild(sidenoteColumn);

  var sidenoteIndex = 1;
  var sidenoteData = [];
  var positionedAtDesktopWidth = false;

  function transformToEpigraph(blockquote) {
    var html = blockquote.innerHTML.trim();

    // Split on the last em-dash to separate quote from attribution
    var dashIndex = html.lastIndexOf(' — ');
    var quoteHtml, attributionHtml;
    if (dashIndex !== -1) {
      quoteHtml = html.substring(0, dashIndex);
      attributionHtml = html.substring(dashIndex + 3).replace(/<\/p>\s*$/, '').trim();
    } else {
      quoteHtml = html;
      attributionHtml = null;
    }

    // Strip the <p> wrapper and leading/trailing quotes
    quoteHtml = quoteHtml.replace(/^<p>\s*/, '').replace(/\s*<\/p>$/, '');
    quoteHtml = quoteHtml.replace(/^[""\u201C\u201D]/, '').replace(/[""\u201C\u201D]$/, '');

    // Build the epigraph structure
    blockquote.className = 'epigraph';
    blockquote.innerHTML = '';

    var quoteP = document.createElement('p');
    quoteP.innerHTML = quoteHtml;
    blockquote.appendChild(quoteP);

    if (attributionHtml) {
      var footer = document.createElement('footer');
      footer.innerHTML = attributionHtml;
      blockquote.appendChild(footer);
    }
  }

  blockquotes.forEach(function(blockquote) {
    var prevElement = blockquote.previousElementSibling;
    if (!prevElement || prevElement.tagName === 'BLOCKQUOTE') return;

    // Transform quotations (blockquotes starting with " or curly ") into epigraphs
    var firstChar = blockquote.textContent.trim().charAt(0);
    if (firstChar === '"' || firstChar === '\u201C') {
      transformToEpigraph(blockquote);
      return;
    }

    // Add reference marker before the blockquote
    var ref = document.createElement('div');
    ref.className = 'sidenote-ref';
    ref.id = 'sidenote-ref-' + sidenoteIndex;
    ref.setAttribute('data-sidenote', sidenoteIndex);
    ref.innerHTML = '<span class="sidenote-arrows">›››</span><span class="sidenote-label">note ' + sidenoteIndex + '</span><span class="sidenote-arrows">›››</span>';
    prevElement.parentNode.insertBefore(ref, blockquote);

    // Mark original blockquote for mobile display
    blockquote.classList.add('sidenote');
    blockquote.classList.add('sidenote-inline');
    blockquote.setAttribute('data-sidenote', sidenoteIndex);

    // Clone blockquote for sidenote column (desktop display)
    var clone = blockquote.cloneNode(true);
    clone.classList.remove('sidenote-inline');
    clone.classList.add('sidenote-margin');
    clone.id = 'sidenote-' + sidenoteIndex;

    // Add number to the clone
    var noteNum = document.createElement('span');
    noteNum.className = 'sidenote-num';
    noteNum.textContent = sidenoteIndex;
    clone.insertBefore(noteNum, clone.firstChild);

    // Add back arrow to the clone
    var backArrow = document.createElement('a');
    backArrow.className = 'sidenote-back';
    backArrow.href = '#sidenote-ref-' + sidenoteIndex;
    backArrow.textContent = ' ↩';
    backArrow.title = 'Back to note ' + sidenoteIndex;
    var lastPara = clone.querySelector('p:last-of-type');
    if (lastPara) {
      lastPara.appendChild(backArrow);
    } else {
      clone.appendChild(backArrow);
    }

    // Click handler on ref bar to scroll to sidenote
    ref.style.cursor = 'pointer';
    ref.addEventListener('click', function(e) {
      e.preventDefault();
      var target = document.getElementById('sidenote-' + ref.getAttribute('data-sidenote'));
      if (target) {
        target.scrollIntoView({ behavior: 'smooth', block: 'center' });
      }
    });

    sidenoteColumn.appendChild(clone);
    sidenoteData.push({ ref: ref, sidenote: clone });
    sidenoteIndex++;
  });

  // Position sidenotes vertically (only needed for desktop, CSS handles visibility)
  function positionSidenotes() {
    // Already positioned successfully, or not at desktop width (refs hidden)
    if (positionedAtDesktopWidth) return;
    if (sidenoteData.length === 0 || sidenoteData[0].ref.offsetWidth === 0) return;

    var contentRect = content.getBoundingClientRect();
    var lastBottom = 0;

    sidenoteData.forEach(function(item) {
      var refRect = item.ref.getBoundingClientRect();
      var desiredTop = refRect.top - contentRect.top;
      var actualTop = Math.max(desiredTop, lastBottom + 10);
      item.sidenote.style.top = actualTop + 'px';
      lastBottom = actualTop + item.sidenote.offsetHeight;
    });

    positionedAtDesktopWidth = true;
  }

  // Position after DOM is ready and after images load
  positionSidenotes();
  window.addEventListener('load', positionSidenotes);
  window.addEventListener('resize', positionSidenotes);

  document.querySelectorAll('img').forEach(function(img) {
    if (!img.complete) {
      img.addEventListener('load', positionSidenotes);
    }
  });
})();
