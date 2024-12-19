<?php
/**
 * SortView
 *
 * Sort and change views of catalogues items 
 * 
 * @category    snippet
 * @version     1.3
 * @internal    @modx_category Content
 * @license     http://www.gnu.org/copyleft/gpl.html GNU Public License (GPL)
 */

if (!defined('MODX_BASE_PATH')) { die('What are you doing? Get out of here!'); }

// Get snippet parameters
$param = $modx->event->params;

// Core parameters
$tplGrid = isset($param['tplGrid']) ? $param['tplGrid'] : 'BS4-DL-BOX-SHOP-tpl';
$tplList = isset($param['tplList']) ? $param['tplList'] : 'BS4-DL-ROWS-tpl';
$defaultSort = isset($param['defaultSort']) ? $param['defaultSort'] : 'menuindex';
$defaultOrder = isset($param['defaultOrder']) ? $param['defaultOrder'] : 'ASC';
$defaultView = isset($param['defaultView']) ? $param['defaultView'] : 'grid';
$defaultDisplay = isset($param['defaultDisplay']) ? $param['defaultDisplay'] : '10';
$viewMode = isset($param['viewMode']) ? strtolower($param['viewMode']) : 'select';

// SortOrder
$sortOrderMode = isset($param['sortOrderMode']) ? strtolower($param['sortOrderMode']) : 'select';
$sortOrderBtnClass = isset($param['sortOrderBtnClass']) ? $param['sortOrderBtnClass'] : 'btn btn-outline-secondary btn-sm';
$sortOrderBtnActiveClass = isset($param['sortOrderBtnActiveClass']) ? $param['sortOrderBtnActiveClass'] : 'active';
$sortOrderBtnGroupClass = isset($param['sortOrderBtnGroupClass']) ? $param['sortOrderBtnGroupClass'] : 'btn-group';
$ascLabel = isset($param['ascLabel']) ? $param['ascLabel'] : '<i class="fa fa-sort-amount-asc"></i>';
$descLabel = isset($param['descLabel']) ? $param['descLabel'] : '<i class="fa fa-sort-amount-desc"></i>';

// Labels
$gridLabel = isset($param['gridLabel']) ? $param['gridLabel'] : 'Grid';
$listLabel = isset($param['listLabel']) ? $param['listLabel'] : 'List';
$DESCLabel = isset($param['DESCLabel']) ? $param['DESCLabel'] : 'Descending';
$ASCLabel = isset($param['ASCLabel']) ? $param['ASCLabel'] : 'Ascending';
$displayLabel = isset($param['displayLabel']) ? $param['displayLabel'] : 'Mostra:';

// CSS Classes
$sortBySelClass = isset($param['sortBySelClass']) ? $param['sortBySelClass'] : 'form-control form-control-sm';
$sortOrderSelClass = isset($param['sortOrderSelClass']) ? $param['sortOrderSelClass'] : 'form-control form-control-sm';
$viewSelClass = isset($param['viewSelClass']) ? $param['viewSelClass'] : 'form-control form-control-sm';
$displaySelClass = isset($param['displaySelClass']) ? $param['displaySelClass'] : 'form-control form-control-sm';
$viewBtnClass = isset($param['viewBtnClass']) ? $param['viewBtnClass'] : 'btn btn-outline-secondary btn-sm';
$viewBtnActiveClass = isset($param['viewBtnActiveClass']) ? $param['viewBtnActiveClass'] : 'active';
$viewBtnGroupClass = isset($param['viewBtnGroupClass']) ? $param['viewBtnGroupClass'] : 'btn-group';

// Container Classes
$sortByOutClass = isset($param['sortByOutClass']) ? $param['sortByOutClass'] : 'form-group mr-2';
$sortOrderOutClass = isset($param['sortOrderOutClass']) ? $param['sortOrderOutClass'] : 'form-group mr-2';
$viewOutClass = isset($param['viewOutClass']) ? $param['viewOutClass'] : 'form-group mr-2';
$displayOutClass = isset($param['displayOutClass']) ? $param['displayOutClass'] : 'form-group';

// Process form submission
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['action']) && $_POST['action'] === 'sortview') {
    $_SESSION['sortview_sort'] = isset($_POST['sort']) ? $_POST['sort'] : $defaultSort;
    $_SESSION['sortview_order'] = isset($_POST['order']) ? $_POST['order'] : $defaultOrder;
    $_SESSION['sortview_view'] = isset($_POST['view']) ? $_POST['view'] : $defaultView;
    $_SESSION['sortview_display'] = isset($_POST['display']) ? $_POST['display'] : $defaultDisplay;
}

// Get current values
$sortBy = isset($_SESSION['sortview_sort']) ? $_SESSION['sortview_sort'] : $defaultSort;
$sortOrder = isset($_SESSION['sortview_order']) ? $_SESSION['sortview_order'] : $defaultOrder;
$viewType = isset($_SESSION['sortview_view']) ? $_SESSION['sortview_view'] : $defaultView;
$display = isset($_SESSION['sortview_display']) ? $_SESSION['sortview_display'] : $defaultDisplay;

// Sort options
$sortOptions = isset($param['sortOptions']) ? $param['sortOptions'] : 'pagetitle,menuindex,price';
$sortOptionsLabels = isset($param['sortOptionsLabels']) ? $param['sortOptionsLabels'] : '';
$sortFields = array_map('trim', explode(',', $sortOptions));
$sortLabelsArray = !empty($sortOptionsLabels) ? array_map('trim', explode(',', $sortOptionsLabels)) : array();

// Build sort options HTML
$sortOptionsHtml = '';
foreach ($sortFields as $index => $field) {
    $label = isset($sortLabelsArray[$index]) ? $sortLabelsArray[$index] : ucfirst($field);
    $selected = $sortBy === $field ? ' selected="selected"' : '';
    $sortOptionsHtml .= sprintf('<option value="%s"%s>%s</option>', $field, $selected, $label);
}

// Display options
$displayOptions = isset($param['displayOptions']) ? $param['displayOptions'] : '5||10||20||30||40||all==tutti';
$displayOptionsHtml = '';
foreach (explode('||', $displayOptions) as $option) {
    $parts = explode('==', $option);
    $value = $parts[0];
    $label = isset($parts[1]) ? $parts[1] : $value;
    $selected = $display === $value ? ' selected="selected"' : '';
    $displayOptionsHtml .= sprintf('<option value="%s"%s>%s</option>', $value, $selected, $label);
}

// Prepare view selector
if ($viewMode === 'buttons') {
    // Non usiamo sprintf per evitare problemi con l'HTML nelle label
    $viewSelector = '
        <div class="'.$viewBtnGroupClass.'">
            <button type="submit" name="view" value="grid" class="'.$viewBtnClass.($viewType === 'grid' ? ' '.$viewBtnActiveClass : '').'">'
                .$gridLabel.
            '</button>
            <button type="submit" name="view" value="list" class="'.$viewBtnClass.($viewType === 'list' ? ' '.$viewBtnActiveClass : '').'">'
                .$listLabel.
            '</button>
        </div>';
} else {
    // Per il select dobbiamo comunque codificare per sicurezza
    $viewSelector = sprintf('
        <select name="view" class="%s">
            <option value="grid"%s>%s</option>
            <option value="list"%s>%s</option>
        </select>',
        $viewSelClass,
        ($viewType === 'grid' ? ' selected="selected"' : ''), htmlspecialchars($gridLabel),
        ($viewType === 'list' ? ' selected="selected"' : ''), htmlspecialchars($listLabel)
    );
}
// Prepara il selettore dell'ordinamento
if ($sortOrderMode === 'buttons') {
    $orderSelector = '<div class="'.$sortOrderBtnGroupClass.'">
        <button type="submit" name="order" value="ASC" class="'.$sortOrderBtnClass.($sortOrder === 'ASC' ? ' '.$sortOrderBtnActiveClass : '').'">'
            .$ascLabel.
        '</button>
        <button type="submit" name="order" value="DESC" class="'.$sortOrderBtnClass.($sortOrder === 'DESC' ? ' '.$sortOrderBtnActiveClass : '').'">'
            .$descLabel.
        '</button>
    </div>';
} else {
    $orderSelector = '<select name="order" class="'.$sortOrderSelClass.'">
        <option value="ASC"'.($sortOrder === 'ASC' ? ' selected="selected"' : '').'>'.htmlspecialchars($ASCLabel).'</option>
        <option value="DESC"'.($sortOrder === 'DESC' ? ' selected="selected"' : '').'>'.htmlspecialchars($DESCLabel).'</option>
    </select>';
}

// Build form HTML
$output = '<div class="sortview-container mb-4">
    <form method="POST" action="'.$_SERVER['REQUEST_URI'].'" id="sortviewForm" class="form-inline justify-content-end">
        <input type="hidden" name="action" value="sortview">
        
        <div class="'.$sortByOutClass.'">
            <select name="sort" class="'.$sortBySelClass.'">'.$sortOptionsHtml.'</select>
        </div>
        
        <div class="'.$sortOrderOutClass.'">'
            .$orderSelector.
        '</div>
        
        <div class="'.$viewOutClass.'">'.$viewSelector.'</div>
        
        <div class="'.$displayOutClass.'">
            <select name="display" class="'.$displaySelClass.'">'.$displayOptionsHtml.'</select>
        </div>
    </form>
</div>';

// Set placeholders
$modx->setPlaceholder('sv_sortBy', $sortBy);
$modx->setPlaceholder('sv_sortOrder', $sortOrder);
$modx->setPlaceholder('sv_tpl', $viewType === 'grid' ? $tplGrid : $tplList);
$modx->setPlaceholder('sv_display', $display === 'all' ? '' : $display);

// Register JavaScript
$js = "
jQuery(document).ready(function($) {
    var form = $('#sortviewForm');
    
    form.find('select').on('change', function() {
        form.submit();
    });
    
    form.find('button[name=\"view\"]').on('click', function(e) {
        e.preventDefault();
        form.find('input[name=\"view\"]').remove();
        form.append('<input type=\"hidden\" name=\"view\" value=\"' + $(this).val() + '\">');
        form.submit();
    });
});";

$modx->regClientScript("<script type=\"text/javascript\">".$js."</script>");

return $output;