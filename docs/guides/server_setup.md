# Server Setup

## Routing

The server routing is where your API hooks are defined. In Rails, this can be found in `config/routes.rb`. I put my API methods behind a /api scope.

In the `scope` block, you can define the individual hooks available to the client for communicating with the server. Use the `match` method to handle each hook.

```ruby
scope "/api" do
	match "todo_items" => "todo_items#index", :via => :get
	match "todo_item" => "todo_items#save", :via => :post
	match "todo_item" => "todo_items#delete", :via => :delete
end
```
		
Also be sure to have your default routes in place.

```ruby
root :to => 'application#layout_only'
match "*path" => "application#layout_only", :constraints => QuickScript::DEFAULT_ROUTING_RULE
```
		
