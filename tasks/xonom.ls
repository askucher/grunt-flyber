module.exports = (grunt)->
  grunt.register-task do 
      * \xonom
      * 'Generate api service and route for express'
      * ->
            input = @options!.input
            output = @options!.output
            prefix = @options!.prefix ? \/
            make-service = @options!.make-service ? (name)->
                !->
                    const args = [].slice.call(arguments)
                    const callback = args.pop!
                    options = 
                        method: \POST
                        headers: 
                          internal: "yes"
                        data: args 
                    $http(options).then do 
                        * (data)->
                            callback null, data.result
                        * (err)->
                            callback err
            const make-route = @options!.make-route ? (func) ->
                (req, resp, next) !->
                    if req.headers.internal is \yes
                        body = req.body ? []
                        body.push (result)->
                          resp.send do 
                              result: result
                        func.apply this, body
                    else 
                        next!
            
            #input: server controllers filenames array
            #output: generated angular service 'api'
            const fs = require \fs
            const map = (f, xs) -->
              [f x for x in xs]
            const make-obj = -> "{#it}"
        
            const join = (d, arr) -->
               arr.join d
            const make-angular-service = (content)->
                "angular.module('xonom', []).service('$xonom', function($http) {
                    \r\n var make = #{make-service.to-string!};
                   \r\n return #content 
                \r\n});"
            const get-methods = (str)->
                        const module = {}
                        const require = -> ->
                        eval str, module, require
                        const res = []
                        
                        const exports =
                            | typeof module.exports is \function => module.exports!
                            | _ => module.exports
                        for m of exports
                          if typeof exports[m] is \function
                            res.push m
                        res
            const get-methods-from-file = fs.read-file-sync >> (.to-string(\utf-8)) >> get-methods
            const camelize = (str)->
                  const cp = (m , c)->
                    if c then c.to-upper-case! else ""
                  str.replace /[-_\s]+(.)?/g , cp
            const generate-obj = (filename) ->
                
                
                const module = 
                   filename.match(/([a-z-]+)\.api/i)?1
                #console.log filename, module
                
                const wrap = -> "(#it)"
                
                
                
                const camel = 
                    camelize module
                    
                const make-named-obj = (content)->
                    "\r\n   #camel : #content"
                const generate-object = (name)->
                  "
                     \r\n     #name : make('#{prefix}#{module}/#name')
                  "
                
                filename |> get-methods-from-file
                         |> map generate-object
                         |> join \,
                         |> make-obj
                         |> make-named-obj
            input.controllers |> map generate-obj
                              |> join \,
                              |> make-obj
                              |> make-angular-service
                              |> fs.write-file-sync output.angular-service, _
            const path = require \path
            const map-route = (filename) ->
                const module = 
                   filename.match(/([a-z-]+)\.api/i).1
                const camel = 
                    camelize module
                const abs = path.resolve filename
                const wrap-controller = (content)->
                    " var #camel = $xonom.require('#abs');\r\n
                      
                      #content
                    "
                const apply-route = (name)->
                   " $router.post('#{prefix}#{module}/#name', make(#camel.#name));
                   "
                
                filename |> get-methods-from-file
                         |> map apply-route
                         |> join \\r\n
                         |> wrap-controller
                
            const apply-template = (content)->
              "module.exports = function($router, $xonom) {\r\n
                     var make = #{make-route.to-string!};\r\n
                     #content \r\n
                  }
              " 
            
            input.controllers |> map map-route
                              |> join \\r\n
                              |> apply-template
                              |> fs.write-file-sync output.express-route, _
