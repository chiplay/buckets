mongoose = require 'mongoose'
chrono = require 'chrono-node'

db = require '../lib/database'

Schema = mongoose.Schema

entrySchema = new Schema
  title:
    type: String
    required: yes
  description: String
  slug:
    type: String
  status:
    type: String
    enum: ['hidden', 'draft', 'live']
    required: yes
    default: 'draft'
  lastModified:
    type: Date
  publishDate:
    type: Date
    default: Date.now
  createdDate:
    type: Date
    default: Date.now
  author:
    type: Schema.Types.ObjectId
    ref: 'User'
  bucket:
    type: Schema.Types.ObjectId
    ref: 'Bucket'
  keywords: [
    type: String
  ]
,
  strict: no

entrySchema.pre 'save', (next) ->
  @lastModified = Date.now()
  next()

entrySchema.path('publishDate').set (val) ->
  parsed = chrono.parse(val)
  if parsed?[0]?.startDate
    parsed[0].startDate
  else
    Date.now()

entrySchema.path('description').validate (val) ->
  val?.length < 140
, 'Descriptions must be less than 140 characters.'

entrySchema.set 'toJSON', virtuals: true

module.exports = db.model 'Entry', entrySchema
