({
    disconnectCometd : function(component) {
        console.log('START disconnectCometd');

        var cometd = component.get('v.cometd');

        // Unsuscribe all CometD subscriptions
        cometd.batch(function() {
            var subscriptions = component.get('v.cometdSubscriptions');
            subscriptions.forEach(function (subscription) {
                cometd.unsubscribe(subscription);
            });
        });
        component.set('v.cometdSubscriptions', []);

        // Disconnect CometD
        cometd.disconnect();
        console.log('CometD disconnected.');

        console.log('END disconnectCometd');
    },

    connectCometd : function(component) {
        console.log('START connectCometd');

        var helper = this;

        // Configure CometD
        var cometdUrl = window.location.protocol + '//' + window.location.hostname + '/cometd/40.0/';
        // var cometdUrl = window.location.protocol + '//' + window.location.hostname + '/cometd/42.0/';
        var cometd = component.get('v.cometd');
        cometd.configure({
            url : cometdUrl,
            requestHeaders : {
                Authorization: 'OAuth ' + component.get('v.sessionId')
            },
            appendMessageTypeToURL : false
        });
        cometd.websocketEnabled = false;

        // Establish CometD connection
        console.log('Connecting to CometD: ' + cometdUrl);
        cometd.handshake(function(handshakeReply) {
            if (handshakeReply.successful) {
                console.log('Connected to CometD.');
                // Subscribe to platform event
                var newSubscription = cometd.subscribe('/event/Notification__e', function(platformEvent) {
                    console.log('Platform event received: ' + JSON.stringify(platformEvent));
                    helper.onReceiveNotification(component, platformEvent);
                });

                // Save subscription for later
                var subscriptions = component.get('v.cometdSubscriptions');
                subscriptions.push(newSubscription);
                component.set('v.cometdSubscriptions', subscriptions);
            } else {
                console.error('Failed to connected to CometD.');
            }
        });

        console.log('END connectCometd');
    },

    displayToast : function(component, type, message) {
        console.log('START displayToast');

        var toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            type: type,
            message: message
        });
        toastEvent.fire();

        console.log('END displayToast');
    },

    onReceiveNotification : function(component, platformEvent, event) {
        console.log('START onReceiveNotification');

        var helper = this;

        // Extract notification from platform event
        var newNotification = {
            time : $A.localizationService.formatDateTime(platformEvent.data.payload.CreatedDate, 'yyyy/MM/DD HH:mm:ss'),
            email : platformEvent.data.payload.Email__c,
            notifier : platformEvent.data.payload.Notifier__c,
            message  : platformEvent.data.payload.Message__c
        };
        // Save notification in history
        // var notifications = component.get('v.notifications');
        // notifications.push(newNotification);
        // component.set('v.notifications', notifications);
        // // Display notification in a toast if not muted
        // if (!component.get('v.isMuted')) {
        //     helper.displayToast(component, 'info', newNotification.message);
        // }

        // pass message to my Einstein components
        console.log(JSON.stringify(newNotification));
        component.set("v.message", newNotification.message);
        component.set("v.time", newNotification.time);
        component.set("v.notifier", newNotification.notifier);
        component.set("v.email", newNotification.email);

        helper.displayToast(component, 'success', 'successfully received from Cat Watch!');
        console.log('END onReceiveNotification');
    },

    onPostMessage: function(component, event, document, type) {
        console.log('START onPostMessage');

        var self = this;
        var action;
        if ('intent' === type) {
            action = component.get("c.callEinsteinIntent");
        } else if ('sentiment' === type) {
            action = component.get("c.callEinsteinSentiment");
        }
        action.setParams({
          "document" : document
        });
        action.setCallback(this, function(data) {
            component.set("v.spinnerWaiting", false);
            var state = data.getState();
            self.handleError(state);
            var result = JSON.parse(data.getReturnValue());
            var results = [];

            if ($A.util.isEmpty(result[0])) {
                if ('intent' === type) {
                    component.set("v.intents", []);
                } else if ('sentiment' === type) {
                    component.set("v.sentiments", []);
                }
                return;
            }

            var probabilities = result[0].probabilities;
            for (var i in probabilities) {
                results.push({
                    "label"       : probabilities[i].label,
                    "probability" : self.calculatePercentage(probabilities[i].probability, 2)
                });
            }
            if ('intent' === type) {
                component.set("v.intents", results);
            } else if ('sentiment' === type) {
                component.set("v.sentiments", results);
            }
        });

        component.set("v.spinnerWaiting", true);
        $A.enqueueAction(action);

        console.log('END onPostMessage');
    },

    handleError : function(state) {
        if (state === 'ERROR') {
            console.log('START handleError');
            var errors = response.getError();
            if (!errors) {
                return console.log("Unknown error");
            }
            if (errors[0] && errors[0].message) {
                return alert(errors[0].message);
            }
            console.log('END handleError');
        }
    },

    calculatePercentage : function(number, place){
        console.log('START calculatePercentage');

        var _pow = Math.pow(10, place);
        var answer = number * 100;
        answer = answer * _pow;
        answer = Math.round(answer);
        answer = answer / _pow;

        return answer;
    }

})