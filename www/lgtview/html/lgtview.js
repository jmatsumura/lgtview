Ext.Loader.setPath('Ext.ux', 'ux');
Ext.Loader.setConfig({enabled: true});

Ext.onReady(function(){
     var conf = {
        db: 'lgtview_example',
        host: '172.18.0.1:27017',
		site: 'https://localhost:443/twinblast.html'
		site: 'http://localhost:8080/twinblast.html'
    };
    var allStores = [];
    var portlets = {
        0 : [],
        1: []};

    var get_metadata = 0;
    Ext.regModel('gene',{
/*        defaults:{
            width: 120,
            sortable: true
        }*/
/*        fields: [
            {mapping: '_id',name: 'Sample Type',type: 'string'},
            {name: 'count', type: 'int'}
        ]*/
    });

    var offset = 0;
    addWindow({'name': 'euk_genus',
               'title': 'Euk Genus',
               'modname': 'euk_genus'
              });

    addWindow({'name': 'euk_ref',
               'title': 'Eukaryote Mappings',
               'modname': 'euk_ref'});

    addWindow({'name': 'bac_genus',
               'title': 'Bac Genus',
               'modname': 'bac_genus'});

    Ext.regModel('filters',{
        fields: [
            {name: 'key',type: 'string'},
            {name: 'value', type: 'string'},
            {name: 'op', type: 'string'}
        ]
    });
    var filterstore = new Ext.data.Store({
        model: 'filters',
        proxy: {
            type: 'memory',
            reader: {
                type: 'json',
                root: 'loads'
            }
        }
    });    
    var cellEditing = Ext.create('Ext.grid.plugin.CellEditing', {
        clicksToEdit: 1
    });
    var filtergrid = new Ext.grid.Panel({
        store: filterstore,
        forcefit: true,
//        width: '100%',
//        height: '100%',
        anchor: '100%, 100%',
        flex: 1,
        selModel: {
            selType: 'cellmodel'
        },
        plugins: [cellEditing],
        columns: [
            {text: 'Key', dataIndex: 'key', type: 'string',width: 80},
            {header: 'Op',
            dataIndex: 'op',
            width: 60,
            field: {
                xtype: 'combobox',
                typeAhead: true,
                triggerAction: 'all',
                selectOnTab: true,
                store: [
                    ['=','eq'],
                    ['!=','ne']
                ],
                lazyRender: true,
                listClass: 'x-combo-list-small'
            }},
            {text: 'value', dataIndex: 'value', type: 'string', width:80, editor: {xtype: 'textfield'}},

            {xtype: 'actioncolumn',
                width: 20,
                items: [{
                    icon   : 'delete.gif',  // Use a URL in the icon config
                    tooltip: 'Remove filter',
                    handler: function(grid, rowIndex, colIndex) {
                        var rec = filterstore.getAt(rowIndex);
//                        delete allfilters[rec.data.key]
                        filterstore.remove(rec);
                        loadData();
                    }
                }]
            }
        ]
    });

    var min_euk_len = new Ext.form.field.Text({
        fieldLabel: 'min euk length',
        value: 15,
        name: 'min_euk_len'
    });
    var min_bac_len = new Ext.form.field.Text({
        fieldLabel: 'min bac length',
        value: 15,
        name: 'min_bac_len'
    });
    var chosen_euk_genus = new Ext.form.field.Text({
        fieldLabel: 'eukaryote genus',
        name: 'chosen_euk_genus'
    });
    var chosen_bac_genus = new Ext.form.field.Text({
        fieldLabel: 'bacteria genus',
        name: 'chosen_bac_genus'
    });
    /*var blast_gen = new Ext.form.field.Text({
        fieldLabel: 'BLAST genus',
        name: 'blast_gen'
    });*/
    /*var blast_valid = new Ext.form.field.Checkbox({
        fieldLabel: 'Valid BLAST',
        name: 'blast_val'
    });*/
    /*var prinseq_derep = new Ext.form.field.Checkbox({
        fieldLabel: 'Prinseq Dereplication',
        name: 'prinseq_rep'
    });*/
    var filterform = new Ext.form.Panel({
//        height: '100%',
        width: '100%',
        frame: true,
        items: [min_euk_len,min_bac_len,chosen_euk_genus,chosen_bac_genus]
    });

    Ext.regModel('reads',{
/*        defaults:{
            width: 120,
            sortable: true
        }*/
/*        fields: [
            {name: 'read',type: 'string'},
            {name: 'twinblast', type: 'string'},
        ]*/
    });

    var readgrid;
    var configured = false;
    var readstore = new Ext.data.Store({
        model: 'reads',
        pageSize: 100,
        proxy: {
            type: 'ajax',
			timeout: 5000000,
            url: '/cgi-bin/view.cgi',
            extraParams: {
                'db': conf.db,
                'host': conf.host
            },
            reader: {
                type: 'json',
                root: 'retval'
            }
        },
        listeners: {
            metachange : function(store,meta) {
                if(!configured && meta != undefined) {
                    Ext.each(meta.columns, function(col) {
                        if(col.dataIndex =='read') {
                            col.renderer = function(value,p,record) {
                                return '<a target=_blank href=' + conf.site + '#?id='+
                                    value+
                                    '&file=example_blastn.out>'+
                                    value+
                                    '</a>';
                            }
                        }
                    });
                    readgrid.reconfigure(store,meta.columns);
                    configured = true;
                }
            }
        }
    });
    
    readgrid = new Ext.grid.Panel({
        store: readstore,
        title: 'Reads',
        region: 'south',
        forcefit: true,
        height: 300,
        split: true,
//        flex: 1,
        columns: [],
        // paging bar on the bottom
        bbar: Ext.create('Ext.PagingToolbar', {
            store: readstore,
            displayInfo: true,
            displayMsg: 'Displaying reads {0} - {1} of {2}',
            emptyMsg: "No reads to display"
        }),
    });
    var bacwin = new Ext.Panel({
        title: 'Bacterial Mappings',
        layout: 'fit',
        split: true,
        region: 'east',
//        x: 150,
//        y: 10,
        width: 500,
//        height: 400,
        autoScroll: true,
        loader: {
            loadMask: false
        },
        items: [{
            xtype : 'component',
            id    : 'bac-iframe',
            autoEl : {
                tag : "iframe",
            }
        }]
//        items: bacchart
//        items: bacbar
    });
//    bacwin.show();

	var titlebar = new Ext.Panel({
		height: 54,
        region: 'north',
        forcefit: true,
        layout: 'hbox',
        items: [
        {width: 260,
        xtype: 'container',
//      padding: '0',
        html: '<img height=50px src=lgtview_logo_50px_trans.png>'},
        {width: 800,
        xtype: 'container',
            padding: '10 0 0 10',
		html: '<i>The reads below are putative Lateral Gene Transfer reads. They are paired-end reads where one mate maps to a donor genome and the other mate maps to a host genome. Clicking on the pie charts will filter the reads in the display. Selecting/deselecting elements from the \'filters\' section will also change the reads in the display. Clicking on a read name in the \'read\' column will open a page with blast results for that read.</i>'},
        {flex: 1,xtype: 'container'}
        ]
	});

    var vp = new Ext.Viewport({
        items: [titlebar,
            {xtype: 'portalpanel',
             id: 'portalpanel',
             region: 'center',
             title: 'Graphs',
             items: [{
                 items: portlets[0]
             },{
                 items: portlets[1]
             }]
/*            tbar: new Ext.Toolbar({
                items: ['Seconds between reload:',
                        reload_combo,
                        {xtype: 'button',
                         text: 'Stop AutoReload',
                         handler: function() {
                             if(this.text == 'Stop AutoReload') {
                                 runner.stop(reload_task);
                                 this.setText('Start AutoReload'); 
                             }
                             else {
                                 runner.start(reload_task);
                                 this.setText('Stop AutoReload'); 
                             }
                         }
                        }]
                
            })*/
            },readgrid,
            bacwin,
            {layout: 'fit',
            region: 'west',
            title: 'Filters',
            buttons: [{text: 'reload',handler: function() { loadData()}}],
            split: true,
            items: [{layout: 'anchor',
//                    align : 'stretch',
//                    pack  : 'start',
                     items: [
                         filterform,
                         filtergrid]
                    }],
             width: 300}],
        layout: 'border',

    });


//    var allStores = [humstore,samplestore,readstore,genestore];
    allStores.push(readstore);
    var allfilters = {};
    loadData();

    function loadData(caller,cond) {
        appendFilter(cond);
//        var caller_id = caller.model.modelName;
        allfilters = {};
        filterstore.each(function(rec) {
            if(rec.data.op == '=') {
                allfilters[rec.data.key] = rec.data.value;
            }
            else if(rec.data.op == '!=') {
                allfilters[rec.data.key] = {'$ne': rec.data.value};
            }
        });
        /*if(cov_field.getValue() != '') {
            allfilters['hu_cov'] = {'$gt' : cov_field.getValue()*1};
        }
        if(blast_gen.getValue() != '') {
            allfilters['bac_blast'] = {'$regex': blast_gen.getValue()};
        }*/
        if(min_euk_len.getValue() != '') {
            allfilters['euk_len'] = {'$gt': min_euk_len.getValue()*1};
        }
        if(min_bac_len.getValue() != '') {
            allfilters['bac_len'] = {'$gt': min_bac_len.getValue()*1};
        }
        if(chosen_euk_genus.getValue() != '') {
            allfilters['euk_genus'] = {'$regex': chosen_euk_genus.getValue()};
        }
        if(chosen_bac_genus.getValue() != '') {
            allfilters['bac_genus'] = {'$regex': chosen_bac_genus.getValue()};
        }
        /*if(blast_valid.getValue()) {
            allfilters['bac_blast_lca'] = 'Bacteria';
        }*/
        /*if(prinseq_derep.getValue()) {
            allfilters['prinseq_rep'] = "";
        }*/

        // Reload the Krona Plot here
        var kronaparams = {
            cond: Ext.encode(allfilters),
            format: 'krona',
            condfield: 'bac_blast_lca'
        }
        Ext.apply(kronaparams,conf);
        Ext.Ajax.request({
            url: '/cgi-bin/view.cgi',
            params: kronaparams,
            success: function(response){
                var res = Ext.decode(response.responseText);
                Ext.getDom('bac-iframe').src = res.file;
            }
        });
         
        Ext.each(allStores, function(store) {
        
            // Monsta hack here. Should do this in a listener on the store!!
/*            if(store.model.modelName =='bac') {
                if(allfilters['hits.genus'] != null) {
                    store.getProxy().extraParams.criteria = 'hits.scientific';
                }
                else {
                    store.getProxy().extraParams.criteria = 'hits.genus';
                }
            }*/
            // Monsta hack here. Should do this in a listener on the store!!
/*            if(store.model.modelName =='gene') {
                if(allfilters['hits.feat_type'] != null) {
                    store.getProxy().extraParams.criteria = 'hits.feat_product';
                }
                else {
                    store.getProxy().extraParams.criteria = 'hits.feat_type';
                }
            }*/
//            if(store.model.modelName != caller_id) {
                Ext.apply(store.getProxy().extraParams,
                    {cond: Ext.encode(allfilters),
                });
                store.load();
//            }
        });
    }
    

    
    function appendFilter(filter) { 
        for(i in filter) if (filter.hasOwnProperty(i)) {
            if(filterstore.findRecord('key',i)) {
                var rec = filterstore.findRecord('key',i);
                rec.set('value',filter[i]);
                rec.set('op', '=');
//                rec.data.op = '=';
 //               allfilters[i] = filter[i];
            }
            else {
//                allfilters[i] = filter[i];
                filterstore.add({
                    'key': i,
                    'op': '=',
                    'value': filter[i]
                });
            }
        }
    }
    function addWindow(params) {

        Ext.regModel(params.modname,{
        fields: [
            {mapping: '_id',name: params.name,type: 'string'},
            {name: 'count', type: 'int'}
        ]
        });
        var newstore = new Ext.data.Store({
            model: params.modname,
            autoLoad: false,
            proxy: {
                type: 'ajax',
                url: '/cgi-bin/view.cgi',
                extraParams: {
                    'criteria': params.name,
                    'db': conf.db,
                    'host': conf.host,
                },
                reader: {
                    type: 'json',
                    root: 'retval'
                }
            }
        });
        var newchart = new Ext.chart.Chart({
            animate: true,
            store: newstore,
            shadow: false,
            legend: {
                position: 'right'
            },
            //insetPadding: 60,
            theme: 'Base:gradients',
            series: [{
                type: 'pie',
                field: 'count',
                //            display: 'none',
                listeners: {

                    'itemmouseup': function(item) {
                        var newparams = [];
                        newparams[params.name] = item.storeItem.data[params.name];
                        loadData(newstore,newparams);
                    }
                },
                tips: {
                    width: 250,
                    renderer: function(storeItem, item) {
                        var title = 'Unknown';
                        if(storeItem.get(params.name)) {
                            title = storeItem.get(params.name);
                        }
                        this.setTitle(title+'<br/>'+storeItem.get('count')+' reads');
                    }
                },
                highlight: {
                    segment: {
                        margin:20
                    }
                },
                label: {
                    field: params.name,
                    display: 'rotate',
                    contrast: true
                }
            }]
        });
        allStores.push(newstore);
        if(portlets[0].length <= portlets[1].length) {
            portlets[0].push({title: '' + params.name,
                              height: 200,
                              items: newchart});
        }
        else {
            portlets[1].push({title: '' + params.name,
                              height: 200,
                              items: newchart});
        }
        
/*        var newwin = new Ext.Window({
            title: params.title,
            layout: 'fit',
            height: 200,
            width: 250,
            x: 100+offset,
            y: 100+offset,
            items: newchart
        });*/
//        newwin.show();    
        offset = offset + 50;
    }

});


