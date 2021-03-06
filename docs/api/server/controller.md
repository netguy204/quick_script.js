# Server Controller

The server controller is responsible for serving the API requests for saving or fetching Model data.

## Defining

`class Controller < ApplicationController`

To setup the server controller, you should first add a `before_filter` which will load your model automatically for each incoming request. This will save you a lot of time later.

```ruby
class TodoItemController < ApplicationController
	before_filter :load_todo_item

	...

	private

	def load_todo_item
		@todo_item = TodoItem.find_by_id(params[:id]) || TodoItem.new
	end
end
```

## Actions

### index

`def index`

Fetches records to respond to the `index` and `load` requests from a ModelAdapter. The standard method will handle both server a single item, or a collection, but ultimately it's up to you.

For handling a single item, you can simply check the `params[:id]`, and server that record if it is found.

For handling a collection, you will need to use the `@scope` variable and `respond_to_scope` helper. `respond_to_scope` works similarly to `respond_to` with Rails, except you are responding to a scoping method (the first string in the `scope` array of the `load` method in a Collection (see client Collection). Within the `respond_to_scope` block, you write separate handlers for each scoping method.

The `respond_to_scope` method automatically handles `offset` and `limit` params sent in the request, so in the scoping function, you need to just select the proper `ActiveRecord::Relation` using `where` clauses.

```ruby
def index
	if params[:id]
		render :json => json_resp(@todo_item.to_api)
	else
		@todo_items = respond_to_scope do |scope|
			scope.all {
				TodoItem
			}
		end
		render :json => json_resp(@todo_items.collect{|t| t.to_api})
	end
end
```
		
Once you have fetched the proper records, you can use the `json_resp` helper to serve them. The methods simply JSON-ifies anything you give it, and builds the response object to send to the client, including the meta field for indicating the status of the response.

The `@scope` variable holds all the details about the request

```ruby
@scope.name = 'for_list'	# name of the scoping method requested
@scope.args = ['list_id_1234']	# array of arguments passed with scope
@scope.limit = 100	# maximum number of records requested
@scope.page = 1			# page of records requested, will automatically determine offset
@scope.offset				# automatically determined from page and limit
```

### save

`def save`

Handles saving the sent client data to storage.

```ruby
def save
	@todo_item.description = params[:description] if params[:description]
	@todo_item.done = params[:done] if params[:done]
	@todo_item.notes = params[:notes] if params[:notes]

	@todo_item.done = false if @todo_item.done.nil?
	@todo_item.save
	render :json => json_resp(@todo_item.to_api)
end
```
		
### delete

`def delete`

Handles deleting the sent client data from storage.

```ruby
def delete
	@todo_item.destroy
	render :json => json_resp(@todo_item.to_api)
end
```

## Module Methods

### json_resp

`json_resp(data_hash, [meta])`

A helper for forming the response to be sent to the client. Builds a JSON string response of format `{data: <data_to_json>, meta: 200|500|404|etc.}`.

* `data_hash` - a hash representation of the data you want to send  
* `meta` - the value indicating the status of the response. Defaults to 200. Note that this does not correspond with the server HTTP response code. The HTTP code denotes whether or not the server was successfully contacted, the meta denotes the status of the response.
	
```ruby
@todo_item = TodoItem.find_by_id(params[:id])
render :json => json_resp(@todo_item, 200)
```

