({
    onInit : function(component, event, helper) {
        console.log('START onInit');

        // component.set('v.cometdSubscriptions', []);
        // component.set('v.notifications', []);

        // Disconnect CometD when leaving page
        window.addEventListener('unload', function(event) {
            helper.disconnectCometd(component);
        });

        // Retrieve session id
        var action = component.get('c.getSessionId');
        action.setCallback(this, function(response) {
            if (component.isValid() && response.getState() === 'SUCCESS') {
                component.set('v.sessionId', response.getReturnValue());
                if (component.get('v.cometd') != null) {
                    helper.connectCometd(component);
                }
            } else {
                console.error(response);
            }
        });
        $A.enqueueAction(action);
        helper.displayToast(component, 'success', 'Einstein Language: Ready to receive notifications.');

        console.log('END onInit');
    },

    onCometdLoaded : function(component, event, helper) {
        console.log('START onCometdLoaded');

        var cometd = new org.cometd.CometD();
        component.set('v.cometd', cometd);
        if (component.get('v.sessionId') != null) {
            helper.connectCometd(component);
        }

        console.log('END onCometdLoaded');
    },

    onReadIntentMessage: function(component, event, helper) {
        console.log('START onReadIntentMessage');

        var message = component.get("v.message");
        helper.onPostMessage(component, event, message, 'intent');

        console.log('END onReadIntentMessage');
    },

    onReadSentimentMessage: function(component, event, helper) {
        console.log('START onReadSentimentMessage');

        var message = component.get("v.message");
        helper.onPostMessage(component, event, message, 'sentiment');

        console.log('END onReadSentimentMessage');
    }

})