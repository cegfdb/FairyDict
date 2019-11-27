import 'bootstrap/dist/css/bootstrap.min.css'
import '../vendor/font-awesome.css'
import './options.less'
# import '../needsharebutton.min.css'

import angular from 'angular'
import utils from "utils"
import $ from 'jquery'
import moment from 'moment'

import 'angular-route'
import 'angular-sanitize'
import 'angular-ui-bootstrap'

# import '../needsharebutton.min.js'
import 'bootstrap/js/scrollspy.js'
import 'bootstrap/js/modal.js'

import 'datatables.net-dt'
import 'datatables.net-bs'
import 'datatables.net-bs/css/dataTables.bootstrap.css'

import 'datatables.net-select'

import 'datatables.net-buttons'
import 'datatables.net-buttons/js/buttons.html5.js'

import 'datatables.net-rowreorder-bs4'
import 'datatables.net-rowreorder-bs4/css/rowReorder.bootstrap4.css'

confirmDelete = (content, twice) ->
    new Promise (resolve) ->
        $('#confirm-delete-modal').off('show.bs.modal').on 'show.bs.modal', () ->
            $('#confirm-delete-modal .modal-body p').text(content)

        $('#confirm-delete-modal .modal-footer .button-confirm').off('click').on 'click', (e) ->
            if twice
                e.stopPropagation() # prevent closing the modal
                confirmDelete('Are you really sure?').then resolve
            else
                resolve()

        $('#confirm-delete-modal').modal('show')

buildActionIcon = (name) ->
    switch name
        when 'remove'
            faIcon = 'fa-remove'
            cls = 'text-danger'

    iEl = "<i class='fa #{faIcon}' aria-hidden='true' data-action='#{name}'></i>"
    return "<a href='' class='action-button #{cls}' data-action='#{name}'> #{iEl} </a>"

buildActionButton = ({ name, cls = '' }) ->
    return "<a href='' class='action-button btn btn-xs #{cls}' data-action='#{name}'> #{name} </a>"

initHistory = () ->
    data = await utils.send 'history'
    table = $('#table-history').DataTable({
        dom: '<"pull-left"f><"pull-left"i><"pull-right"B>tp',
        paging: false,
        select: {
            style: 'os',
            className: 'active'
        },
        buttons: [{
            text: 'Delete',
            className: 'btn btn-danger',
            action: () ->
                twice = false
                rows = table.rows({ selected: true,  filter: 'applied' })
                rowsData = rows.data()
                    .toArray()
                if not rowsData.length
                    rows = table.rows({ filter: 'applied' })
                    rowsData = rows.data()
                        .toArray()
                    if rowsData.length > 10
                        twice = true

                return if not rowsData.length

                confirmDelete("Are you sure you want to delete all #{rowsData.length} records?", twice).then ()->
                    utils.send 'remove history', { w: rowsData.map((item) -> item.w) }
                    rows.remove().draw()

        },{
            extend: 'csv',
            extension: '.csv',
            bom: true,
            text: 'Download',
            filename: 'dictionaries-history',
            className: 'btn btn-info',
            exportOptions: {
                columns: ['w:name', 'r:name', 's:name', 't:name'],
                orthogonal: 'download'
            }
        }],
        order: [[3, 'desc']],
        columns: [
            {
                name: 'w',
                title: 'Word',
                data: 'w'
            },
            {
                name: 'r',
                title: 'Rate',
                data: 'r'
                render: (data, type) ->
                    data || 0
            },
            {
                name: 's',
                title: 'Source',
                data: 's',
                render: (data, type, row) ->
                    return '' unless data
                    return data if type == 'download'
                    return "<a class='column-s' target='_blank' href='#{data}'> #{row.sc || data} </a>"

            },
            {
                name: 't',
                title: 'Time',
                data: 't',
                render: (data, type) ->
                    return moment(data).format('YYYY-MM-DD HH:mm:ss')
            },
            {
                name: 'action',
                title: 'Action',
                render: (data, type) ->
                    if type == 'display'
                        return buildActionIcon 'remove'
                    return ''
            }
        ],
        data
    })

    $('#table-history tbody').on 'click', 'td', (e) ->
        if $(e.currentTarget).has('.action-button').length
            e.preventDefault()
            e.stopPropagation()

            row = table.row($(e.currentTarget).closest('tr'))
            rowData = row.data()

            switch $(e.target).data('action')
                when 'remove'
                    console.log rowData
                    await utils.send 'remove history', rowData
                    row.remove().draw()


initHistory()

initDictionary = () ->
    {currentDictName, allDicts} = await utils.send 'dictionary'

    table = $('#table-dictionary').DataTable({
        dom: 't',
        paging: false,
        # ordering: false,
        rowReorder: {
            dataSrc: 'sequence'
        },
        columns: [
            {
                name: 'sequence',
                title: 'Sequence',
                data: 'sequence',
                visible: false,
                orderable: true
                # render: (data) -> data || 0

            },
            {
                name: 'name',
                title: 'Name',
                data: 'dictName',
                className: 'reorder',
                orderable: false,
                render: (data, type, row) ->
                    if type == 'display'
                        if row.disabled
                            data = "<span class='text-muted'>#{data}</span>"
                        if currentDictName == data
                            data += "&nbsp; <span class='badge'> Current </span>"
                    return data
            },
            {
                name: 'action',
                title: 'Action',
                orderable: false,
                render: (data, type, row) ->
                    if type == 'display'
                        el = ''
                        if currentDictName != row.dictName
                            if row.disabled
                                el += buildActionButton({name: "Enable", cls: "btn-info"})
                            else
                                el += buildActionButton({name: "Activate", cls: "btn-primary"}) + \
                                ' ' + buildActionButton({name: "Disable", cls: "btn-default"})

                        return el

                    return ''

            }
        ],
        data: allDicts
    })

    table.on 'row-reorder', (e, diff) ->
        dicts = diff.map (item) ->
            console.log item, item.oldData, item.newData
            rowData = table.row( item.node ).data()
            rowData.sequence = item.newData
            return rowData
        utils.send 'set-dictionary-reorder', { dicts }

    $('#table-dictionary tbody').on 'click', 'td', (e) ->
        if $(e.currentTarget).has('.action-button').length
            e.preventDefault()
            e.stopPropagation()

            row = table.row($(e.currentTarget).closest('tr'))
            rowData = row.data()

            switch $(e.target).data('action')
                when 'Activate'
                    currentDictName = rowData.dictName
                    await utils.send 'set-dictionary-current', rowData
                    table.rows().invalidate().draw()

                when 'Disable'
                    rowData.disabled = true
                    await utils.send 'set-dictionary-disable', rowData
                    table.rows().invalidate().draw()

                when 'Enable'
                    rowData.disabled = false
                    await utils.send 'set-dictionary-disable', rowData
                    table.rows().invalidate().draw()


initDictionary()

dictApp = angular.module('fairyDictApp', ['ngRoute', 'ui.bootstrap', 'ngSanitize'])

dictApp.controller 'optionCtrl', ($scope, $sce) ->
    console.log "[optionCtrl] init"

    $scope.allSK = ['', 'Ctrl', 'Shift', 'Alt', 'Meta']
    $scope.allLetters = (String.fromCharCode(code) for code in ['A'.charCodeAt(0)..'Z'.charCodeAt(0)])

    $scope.extraKeys = Object.keys(utils.extraKeyMap)

    $scope.allKeys = $scope.allLetters.concat($scope.extraKeys)

    $scope.allPositions = ['topLeft', 'topCenter', 'topRight',
                           'middleLeft', 'middleCenter', 'middleRight',
                           'bottomLeft', 'bottomCenter', 'bottomRight']

    $scope.changeKey = (value, key)->
        $scope.setting[key] = value
        chrome.runtime.sendMessage {
            type: 'save setting'
            key: key,
            value: value
        }

    chrome.runtime.sendMessage {
        type: 'setting'
    }, (config)->
        $scope.setting = config
        $scope.$apply()

