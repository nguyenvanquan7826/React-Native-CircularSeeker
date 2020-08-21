/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 * @flow strict-local
 */

import React, {useState} from 'react';
import {SafeAreaView, StatusBar, Text, View} from 'react-native';
import CircularSeeker from './CircularSeeker';

const App = () => {
    const [value, setValue] = useState(0);
    const [status, setStatus] = useState("");
    return (
        <>
            <StatusBar barStyle="dark-content"/>
            <SafeAreaView>
                <View>
                    <Text style={{fontSize: 50, marginTop:180}}>Temp cc = {value}</Text>
                    <Text style={{fontSize: 30}}>Status = {status}</Text>
                    <CircularSeeker
                        style={{width: 300, height: 300}}
                        startAngle={180}
                        endAngle={0}
                        currentAngle={180}
                        maxVal={30}
                        minVal={16}
                        onUpdate={(event) => {
                            const newVal = event.nativeEvent.progressVal;
                            setValue(newVal);
                            setStatus("moving...")
                        }}
                        onComplete={(event) => {
                            setStatus("Complete")
                        }}
                        seekBarColor="gray"
                        thumbColor="green"
                    />

                </View>
            </SafeAreaView>
        </>
    );
};
export default App;
