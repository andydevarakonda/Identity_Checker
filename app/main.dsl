context {
    input phone: string;
}

// declare external functions here 
external function confirm(signal: string): boolean;
external function status(): string;



start node root {
    do {
        #connectSafe($phone);
        wait *;
    }
    transitions {
        hello: goto hello on true;        
    }
}

node hello {
    do { 
        #sayText("Thank you for submitting your application for Indian RAW Agency");
        #sayText("I'm your artificially intelligent agent, Neptune.");
        wait *;
    }
    transitions {
    }
}


digression status {
    conditions { on #messageHasIntent("status"); }
    do {
        #sayText("Please confirm your identity.");
        #sayText("Name of your Call Sign");
        wait *;
    } 
    transitions {
        confirm: goto confirm on #messageHasData("signal");
    }
}

node confirm {
    do {
        var signal = #messageGetData("signal", { value: true })[0]?.value??"";
        var response = external confirm(signal);
        if (response) {
            #sayText("Great, your identity confirmed. Welcome to RAW");
            //goto approved;
        }
        else {
            #sayText("I'm sorry but your identity is not confirmed. Goodbye");
            //wait *;
        }
    } 
    transitions
    {
        
    }
}



// additional digressions 
digression @wait {
    conditions { on #messageHasAnyIntent(digression.@wait.triggers)  priority 900; }
    var triggers = ["wait", "wait_for_another_person"];
    var responses: Phrases[] = ["i_will_wait"];
    do {
        for (var item in digression.@wait.responses) {
            #say(item, repeatMode: "ignore");
        }
        #waitingMode(duration: 70000);
        return;
    }
    transitions {
    }
}

digression repeat {
    conditions { on #messageHasIntent("repeat"); }
    do {
        #repeat();
        return;
    }
} 
