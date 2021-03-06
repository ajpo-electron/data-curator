<template>
<form class="navbar-form form-horizontal" id="tableProperties">
  <div class="form-group-sm row container-fluid">
    <div class="propertyrow" v-for="(formprop, index) in formprops" :key="index">
      <label v-show="formprop.label" v-tooltip.left="tooltip(formprop.tooltipId)" class="control-label" :for="formprop.label">{{formprop.label}}</label>
      <component :is="formprop.tooltipView"/>
      <input v-if="formprop.key === 'missingValue'" :value="missingValues" @input="setArrayValues(formprop.key, $event.target.value)" type="text" class="form-control input-sm col-sm-9" :id="formprop.key" />
      <component v-else-if="isSharedComponent(formprop.key)" :propertyName="formprop.key" :getProperty="getProperty" :getPropertyGivenHotId="getPropertyGivenHotId" :setProperty="setProperty" :waitForHotIdFromTabId="waitForHotIdFromTabId" :currentHotId="currentHotId" :is="formprop.key"/>
      <input v-else type="text" :class="{ 'form-control input-sm col-sm-9': true, 'validate-danger': errors.has(formprop.key) }" :id="formprop.key" :value="getProperty(formprop.key)" @input="setProperty(formprop.key, $event.target.value)" v-validate="validationRules(formprop.key)" :name="formprop.key"/>
      <div v-show="errors.has(formprop.key) && removeValue(formprop.key)" class="row help validate-danger">
        {{ errors.first(formprop.key)}}
      </div>
    </div>
  </div>
</form>
</template>
<script>
import {
  mapMutations,
  mapState,
  mapGetters
} from 'vuex'
import SideNav from './SideNav'
import Vue from 'vue'
import AsyncComputed from 'vue-async-computed'
import licenses from '../partials/Licenses'
import sources from '../partials/Sources'
import primaryKeys from '../partials/PrimaryKeys'
import foreignKeys from '../partials/ForeignKeys'
import {
  HotRegister
} from '../hot.js'
import TableTooltip from '../mixins/TableTooltip'
import ValidationRules from '../mixins/ValidationRules'
// import {
//   Validator
// } from 'vee-validate'
Vue.use(AsyncComputed)
export default {
  extends: SideNav,
  name: 'tabular',
  mixins: [ValidationRules, TableTooltip],
  components: {
    licenses,
    sources,
    primaryKeys,
    foreignKeys
  },
  data() {
    return {
      formprops: [{
        label: 'Name*',
        key: 'name',
        tooltipId: 'tooltip-table-name',
        tooltipView: 'tooltipTableName'
      }, {
        label: 'Title',
        key: 'title',
        tooltipId: 'tooltip-table-title',
        tooltipView: 'tooltipTableTitle'
      },
      {
        label: 'Description',
        key: 'description',
        tooltipId: 'tooltip-table-description',
        tooltipView: 'tooltipTableDescription'
      },
      {
        label: 'Source(s)',
        key: 'sources',
        type: 'dropdown',
        tooltipId: 'tooltip-table-sources',
        tooltipView: 'tooltipTableSources'
      },
      {
        label: 'License(s)',
        key: 'licenses',
        tooltipId: 'tooltip-table-licences',
        tooltipView: 'tooltipTableLicences'
      },
      {
        label: 'Primary key(s)',
        key: 'primaryKeys',
        tooltipId: 'tooltip-table-primary-keys',
        tooltipView: 'tooltipTablePrimaryKeys'
      },
      {
        // label: 'Foreign key(s)',
        key: 'foreignKeys'
        // tooltipId: 'tooltip-table-foreign-keys',
        // tooltipView: 'tooltipTableForeignKeys'
      },
      {
        label: 'Missing value(s)',
        type: 'array',
        key: 'missingValues',
        tooltipId: 'tooltip-table-missing-values',
        tooltipView: 'tooltipTableMissingValues'
      }
      ]
    }
  },
  asyncComputed: {
    async missingValues() {
      let values = await this.getArrayValues('missingValues')
      return values
    }
  },
  computed: {
    ...mapGetters(['getMissingValuesFromHot', 'getActiveTab', 'getTableProperty', 'getHotTabs'])
  },
  methods: {
    ...mapMutations([
      'pushTableProperty'
    ]),
    getArrayValues: async function(key) {
      let tabId = this.getActiveTab
      let values = await this.getArrayValuesFromTabId(key, tabId)
      // ensure re-render in input
      this.$forceUpdate()
      return values
    },
    setArrayValues: function(key, value) {
      // TODO : hotId could be cached for all methods using it.
      let hot = HotRegister.getActiveInstance()
      if (hot) {
        let array = Array.from(new Set(value.split(',')))
        this.pushTableProperty({
          hotId: hot.guid,
          key: key,
          value: array
        })
      }
    },
    getArrayValuesFromTabId: async function(key, tabId) {
      let hotId = await this.waitForHotIdFromTabId(tabId)
      if (hotId) {
        let array = this.getTableProperty({
          hotId: hotId,
          key: key
        }) || ['']
        let string = array.join()
        return string
      }
    },
    setMissingValues: function(value) {
      let hot = HotRegister.getActiveInstance()
      if (hot) {
        let array = Array.from(new Set(value.split(',')))
        this.pushTableProperty({
          hotId: hot.guid,
          key: 'missingValues',
          value: array
        })
      }
    },
    getProperty: function(key) {
      return this.getTableProperty(this.propertyGetObject(key))
    },
    getPropertyGivenHotId: function(key, hotId) {
      return this.getTableProperty(this.propertyGetObjectGivenHotId(key, hotId))
    },
    setProperty: function(key, value) {
      this.pushTableProperty(this.propertySetObject(key, value))
    },
    removeValue: function(key) {
      this.pushTableProperty(this.propertySetObject(key, ''))
      return true
    }
  },
  mounted: function() {
    this.$validator.extend('unique_name', {
      getMessage: field => `There is already another tab with this ${field}.`,
      validate: value => new Promise((resolve) => {
        let currentNames = _.values(_.mapValues(this.getHotTabs, function(hotTab) {
          return hotTab.tableProperties ? hotTab.tableProperties.name : ''
        }))
        let otherNames = _.without(currentNames, ...value)
        resolve({
          valid: currentNames.length - otherNames.length <= 1
        })
      })
    })
  }
}
</script>
<style lang="styl" scoped>
@import '~static/css/validationrules'
</style>
