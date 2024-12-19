<?php
/**
 * SortView
 *
 * Sort and change views of catalogues items with flexible layout system
 *
 * @author    Nicola Lambathakis http://www.tattoocms.it/
 * @category    snippet
 * @version     2.0
 * @internal    @modx_category Content
 * @license     http://www.gnu.org/copyleft/gpl.html GNU Public License (GPL)
 * @lastupdate  19-12-2024
 */
if (!defined('MODX_BASE_PATH')) {
    die('What are you doing? Get out of here!');
}
// Get snippet parameters
$param = $modx->event->params;
// Core parameters
function parseTpl($tpl, $default = '') {
    if (empty($tpl)) return $default;
    if (substr($tpl, 0, 6) === '@CODE:') {
        return substr($tpl, 6);
    } elseif (substr($tpl, 0, 7) === '@CHUNK:') {
        return substr($tpl, 7); // Ritorna solo il nome del chunk
        
    } else {
        return $tpl; // Ritorna il nome del chunk
        
    }
}
// Template delle view - passa solo il riferimento
$tplGrid = isset($param['tplGrid']) ? parseTpl($param['tplGrid'], '@CODE:Missing Grid tpl!') : '@CODE:Missing Grid tpl!';
$tplList = isset($param['tplList']) ? parseTpl($param['tplList'], '@CODE:Missing List tpl!') : '@CODE:Missing List tpl!';
// Template generale - questo deve essere elaborato subito
function parseLayoutTpl($tpl, $default = '') {
    if (empty($tpl)) return $default;
    if (substr($tpl, 0, 6) === '@CODE:') {
        return substr($tpl, 6);
    } elseif (substr($tpl, 0, 7) === '@CHUNK:') {
        $chunk = substr($tpl, 7);
        return $GLOBALS['modx']->getChunk($chunk);
    } else {
        return $GLOBALS['modx']->getChunk($tpl);
    }
}
$defaultSort = isset($param['defaultSort']) ? $param['defaultSort'] : 'menuindex';
$defaultOrder = isset($param['defaultOrder']) ? $param['defaultOrder'] : 'ASC';
$defaultView = isset($param['defaultView']) ? $param['defaultView'] : 'grid';
$defaultDisplay = isset($param['defaultDisplay']) ? $param['defaultDisplay'] : '10';
// Template and display modes
$template = isset($param['template']) ? $param['template'] : '';
$viewMode = isset($param['viewMode']) ? strtolower($param['viewMode']) : 'select';
$sortOrderMode = isset($param['sortOrderMode']) ? strtolower($param['sortOrderMode']) : 'select';
// Show/Hide components
$showSortBy = isset($param['showSortBy']) ? (bool)$param['showSortBy'] : true;
$showSortOrder = isset($param['showSortOrder']) ? (bool)$param['showSortOrder'] : true;
$showView = isset($param['showView']) ? (bool)$param['showView'] : true;
$showDisplay = isset($param['showDisplay']) ? (bool)$param['showDisplay'] : true;
// Labels
$gridLabel = isset($param['gridLabel']) ? $param['gridLabel'] : 'Grid';
$listLabel = isset($param['listLabel']) ? $param['listLabel'] : 'List';
$DESCLabel = isset($param['DESCLabel']) ? $param['DESCLabel'] : 'Descending';
$ASCLabel = isset($param['ASCLabel']) ? $param['ASCLabel'] : 'Ascending';
$displayLabel = isset($param['displayLabel']) ? $param['displayLabel'] : 'Mostra:';
// CSS Classes
$formClass = isset($param['formClass']) ? $param['formClass'] : 'form-inline justify-content-end';
$selectClass = isset($param['selectClass']) ? $param['selectClass'] : 'form-control form-control-sm';
$btnClass = isset($param['btnClass']) ? $param['btnClass'] : 'btn btn-outline-secondary btn-sm';
$btnActiveClass = isset($param['btnActiveClass']) ? $param['btnActiveClass'] : 'active';
$btnGroupClass = isset($param['btnGroupClass']) ? $param['btnGroupClass'] : 'btn-group';
$blockClass = isset($param['blockClass']) ? $param['blockClass'] : 'form-group mr-2';
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
// Generate form elements
$ph = array(); // Placeholder array
// Form tags
$ph['sv_form_start'] = '<form method="POST" action="' . $_SERVER['REQUEST_URI'] . '" id="sortviewForm" class="' . $formClass . '">
    <input type="hidden" name="action" value="sortview">
    <input type="hidden" name="sort" value="' . $sortBy . '">
    <input type="hidden" name="order" value="' . $sortOrder . '">
    <input type="hidden" name="view" value="' . $viewType . '">
    <input type="hidden" name="display" value="' . $display . '">';
$ph['sv_form_end'] = '</form>';
// SortBy block
if ($showSortBy) {
    $sortOptionsHtml = '';
    foreach ($sortFields as $index => $field) {
        $label = isset($sortLabelsArray[$index]) ? $sortLabelsArray[$index] : ucfirst($field);
        $selected = $sortBy === $field ? ' selected="selected"' : '';
        $sortOptionsHtml.= '<option value="' . $field . '"' . $selected . '>' . $label . '</option>';
    }
    $ph['sv_sortby_select'] = '<select name="sort" class="' . $selectClass . '">' . $sortOptionsHtml . '</select>';
    $ph['sv_sortby_block'] = '<div class="' . $blockClass . '">' . $ph['sv_sortby_select'] . '</div>';
}
// SortOrder block
if ($showSortOrder) {
    if ($sortOrderMode === 'buttons') {
        $ph['sv_btn_asc'] = '<button type="submit" name="order" value="ASC" class="' . $btnClass . ($sortOrder === 'ASC' ? ' ' . $btnActiveClass : '') . '">' . $ASCLabel . '</button>';
        $ph['sv_btn_desc'] = '<button type="submit" name="order" value="DESC" class="' . $btnClass . ($sortOrder === 'DESC' ? ' ' . $btnActiveClass : '') . '">' . $DESCLabel . '</button>';
        $ph['sv_sortorder_block'] = '<div class="' . $blockClass . '"><div class="' . $btnGroupClass . '">' . $ph['sv_btn_asc'] . $ph['sv_btn_desc'] . '</div></div>';
    } else {
        $ph['sv_sortorder_select'] = '<select name="order" class="' . $selectClass . '">
            <option value="ASC"' . ($sortOrder === 'ASC' ? ' selected="selected"' : '') . '>' . $ASCLabel . '</option>
            <option value="DESC"' . ($sortOrder === 'DESC' ? ' selected="selected"' : '') . '>' . $DESCLabel . '</option>
        </select>';
        $ph['sv_sortorder_block'] = '<div class="' . $blockClass . '">' . $ph['sv_sortorder_select'] . '</div>';
    }
}
// View block
if ($showView) {
    if ($viewMode === 'buttons') {
        $ph['sv_btn_grid'] = '<button type="submit" name="view" value="grid" class="' . $btnClass . ($viewType === 'grid' ? ' ' . $btnActiveClass : '') . '">' . $gridLabel . '</button>';
        $ph['sv_btn_list'] = '<button type="submit" name="view" value="list" class="' . $btnClass . ($viewType === 'list' ? ' ' . $btnActiveClass : '') . '">' . $listLabel . '</button>';
        $ph['sv_view_block'] = '<div class="' . $blockClass . '"><div class="' . $btnGroupClass . '">' . $ph['sv_btn_grid'] . $ph['sv_btn_list'] . '</div></div>';
    } else {
        $ph['sv_view_select'] = '<select name="view" class="' . $selectClass . '">
            <option value="grid"' . ($viewType === 'grid' ? ' selected="selected"' : '') . '>' . $gridLabel . '</option>
            <option value="list"' . ($viewType === 'list' ? ' selected="selected"' : '') . '>' . $listLabel . '</option>
        </select>';
        $ph['sv_view_block'] = '<div class="' . $blockClass . '">' . $ph['sv_view_select'] . '</div>';
    }
}
// Display block
if ($showDisplay) {
    $displayOptions = isset($param['displayOptions']) ? $param['displayOptions'] : '5||10||20||30||40||50';
    $displayOptionsHtml = '';
    foreach (explode('||', $displayOptions) as $option) {
        $parts = explode('==', $option);
        $value = $parts[0];
        $label = isset($parts[1]) ? $parts[1] : $value;
        $selected = $display === $value ? ' selected="selected"' : '';
        $displayOptionsHtml.= '<option value="' . $value . '"' . $selected . '>' . $label . '</option>';
    }
    $ph['sv_display_select'] = '<select name="display" class="' . $selectClass . '">' . $displayOptionsHtml . '</select>';
    $ph['sv_display_block'] = '<div class="' . $blockClass . '">' . $ph['sv_display_select'] . '</div>';
}
// Default template if none provided
$defaultTemplate = '<div class="sortview-container mb-4">
    [+sv_form_start+]
        <div class="d-flex flex-wrap align-items-center justify-content-end">
            [+sv_sortby_block+]
            [+sv_sortorder_block+]
            [+sv_view_block+]
            [+sv_display_block+]
        </div>
    [+sv_form_end+]
</div>';
// Parse template
if (empty($template)) {
    $output = $defaultTemplate;
} else {
    $output = parseLayoutTpl($template, $defaultTemplate);
}
foreach ($ph as $key => $value) {
    $output = str_replace('[+' . $key . '+]', $value, $output);
}
// Set placeholders for eFilter/DocLister
$modx->setPlaceholder('sv_sortBy', $sortBy);
$modx->setPlaceholder('sv_sortOrder', $sortOrder);
$modx->setPlaceholder('sv_tpl', $viewType === 'grid' ? $tplGrid : $tplList);
$modx->setPlaceholder('sv_display', $display === 'all' ? '' : $display);
// Register JavaScript
$js = "
jQuery(document).ready(function($) {
    var form = $('#sortviewForm');
    
    // Handle select changes
    form.find('select').on('change', function() {
        form.submit();
    });
    
    // Handle buttons
    form.find('button[name]').on('click', function(e) {
        e.preventDefault();
        var clickedName = $(this).attr('name');
        var clickedValue = $(this).val();
        
        // Aggiorna o crea l'input hidden corrispondente
        var hiddenInput = form.find('input[type=hidden][name=' + clickedName + ']');
        if (hiddenInput.length) {
            hiddenInput.val(clickedValue);
        } else {
            form.append('<input type=\"hidden\" name=\"' + clickedName + '\" value=\"' + clickedValue + '\">');
        }
        
        form.submit();
    });
});";
$modx->regClientScript("<script type=\"text/javascript\">" . $js . "</script>");
return $output;