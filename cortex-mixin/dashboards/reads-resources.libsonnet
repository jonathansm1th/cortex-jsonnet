local utils = import 'mixin-utils/utils.libsonnet';

(import 'dashboard-utils.libsonnet') {
  'cortex-reads-resources.json':
    ($.dashboard('Cortex / Reads Resources') + { uid: '2fd2cda9eea8d8af9fbc0a5960425120' })
    .addClusterSelectorTemplates()
    .addRow(
      $.row('Gateway')
      .addPanel(
        $.containerCPUUsagePanel('CPU', 'cortex-gw'),
      )
      .addPanel(
        $.containerMemoryWorkingSetPanel('Memory (workingset)', 'cortex-gw'),
      )
      .addPanel(
        $.goHeapInUsePanel('Memory (go heap inuse)', 'cortex-gw'),
      )
    )
    .addRow(
      $.row('Query Frontend')
      .addPanel(
        $.containerCPUUsagePanel('CPU', 'query-frontend'),
      )
      .addPanel(
        $.containerMemoryWorkingSetPanel('Memory (workingset)', 'query-frontend'),
      )
      .addPanel(
        $.goHeapInUsePanel('Memory (go heap inuse)', 'query-frontend'),
      )
    )
    .addRow(
      $.row('Query Scheduler')
      .addPanel(
        $.containerCPUUsagePanel('CPU', 'query-scheduler'),
      )
      .addPanel(
        $.containerMemoryWorkingSetPanel('Memory (workingset)', 'query-scheduler'),
      )
      .addPanel(
        $.goHeapInUsePanel('Memory (go heap inuse)', 'query-scheduler'),
      )
    )
    .addRow(
      $.row('Querier')
      .addPanel(
        $.containerCPUUsagePanel('CPU', 'querier'),
      )
      .addPanel(
        $.containerMemoryWorkingSetPanel('Memory (workingset)', 'querier'),
      )
      .addPanel(
        $.goHeapInUsePanel('Memory (go heap inuse)', 'querier'),
      )
    )
    .addRow(
      $.row('Ingester')
      .addPanel(
        $.containerCPUUsagePanel('CPU', 'ingester'),
      )
      .addPanel(
        $.containerMemoryWorkingSetPanel('Memory (workingset)', 'ingester'),
      )
      .addPanel(
        $.goHeapInUsePanel('Memory (go heap inuse)', 'ingester'),
      )
    )
    .addRow(
      $.row('Ruler')
      .addPanel(
        $.panel('Rules') +
        $.queryPanel('sum by(instance) (cortex_prometheus_rule_group_rules{%s})' % $.jobMatcher($._config.job_names.ruler), '{{instance}}'),
      )
      .addPanel(
        $.containerCPUUsagePanel('CPU', 'ruler'),
      )
    )
    .addRow(
      $.row('')
      .addPanel(
        $.containerMemoryWorkingSetPanel('Memory (workingset)', 'ruler'),
      )
      .addPanel(
        $.goHeapInUsePanel('Memory (go heap inuse)', 'ruler'),
      )
    )
    .addRowIf(
      std.member($._config.storage_engine, 'blocks'),
      $.row('Store-gateway')
      .addPanel(
        $.containerCPUUsagePanel('CPU', 'store-gateway'),
      )
      .addPanel(
        $.containerMemoryWorkingSetPanel('Memory (workingset)', 'store-gateway'),
      )
      .addPanel(
        $.goHeapInUsePanel('Memory (go heap inuse)', 'store-gateway'),
      )
    )
    .addRowIf(
      std.member($._config.storage_engine, 'blocks'),
      $.row('')
      .addPanel(
        $.panel('Disk Writes') +
        $.queryPanel('sum by(instance, device) (rate(node_disk_written_bytes_total[$__rate_interval])) + %s' % $.filterNodeDiskContainer('store-gateway'), '{{pod}} - {{device}}') +
        $.stack +
        { yaxes: $.yaxes('Bps') },
      )
      .addPanel(
        $.panel('Disk Reads') +
        $.queryPanel('sum by(instance, device) (rate(node_disk_read_bytes_total[$__rate_interval])) + %s' % $.filterNodeDiskContainer('store-gateway'), '{{pod}} - {{device}}') +
        $.stack +
        { yaxes: $.yaxes('Bps') },
      )
      .addPanel(
        $.panel('Disk Space Utilization') +
        $.queryPanel('max by(persistentvolumeclaim) (kubelet_volume_stats_used_bytes{%s} / kubelet_volume_stats_capacity_bytes{%s}) and count by(persistentvolumeclaim) (kube_persistentvolumeclaim_labels{%s,label_name="store-gateway"})' % [$.namespaceMatcher(), $.namespaceMatcher(), $.namespaceMatcher()], '{{persistentvolumeclaim}}') +
        { yaxes: $.yaxes('percentunit') },
      )
    ) + {
      templating+: {
        list: [
          // Do not allow to include all clusters/namespaces otherwise this dashboard
          // risks to explode because it shows resources per pod.
          l + (if (l.name == 'cluster' || l.name == 'namespace') then { includeAll: false } else {})
          for l in super.list
        ],
      },
    },
}
