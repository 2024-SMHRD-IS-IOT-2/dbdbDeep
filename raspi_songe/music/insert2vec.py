from pinecone import Pinecone
import os
import librosa
import pandas as pd 
from glob import glob
from tqdm import tqdm

## 특성 뽑아서 Pinecone에 넣는 코드!

class InsertMusic():
    def __init__(self,PINECONE_API_KEY):
        self.pc = Pinecone(api_key= PINECONE_API_KEY)
    
    def extract_features(self,path):
        y, sr = librosa.load(path)
        chroma = librosa.feature.chroma_stft(y=y, sr=sr)
        audio_features = dict()
        audio_features['name'] = os.path.splitext(os.path.basename(path))[0]
        audio_features['chroma_stft_mean'] = float(chroma.mean())
        audio_features['chroma_stft_var'] = float(chroma.var())
        rms = librosa.feature.rms(y=y)
        audio_features['rms_mean'] = float(rms.mean())
        audio_features['rms_var'] = float(rms.var())
        spec_cent = librosa.feature.spectral_centroid(y=y, sr=sr)
        audio_features['spectral_centroid_mean'] = float(spec_cent.mean())
        audio_features['spectral_centroid_var'] = float(spec_cent.var())

        spec_bw = librosa.feature.spectral_bandwidth(y=y, sr=sr)
        audio_features['spectral_bandwidth_mean'] = float(spec_bw.mean())
        audio_features['spectral_bandwidth_var'] = float(spec_bw.var())

        spec_rolloff = librosa.feature.spectral_rolloff(y=y, sr=sr)
        audio_features['rolloff_mean'] = float(spec_rolloff.mean())
        audio_features['rolloff_var'] = float(spec_rolloff.var())


        zero_crossing_rate = librosa.feature.zero_crossing_rate(y)
        audio_features['zero_crossing_rate_mean'] = float(zero_crossing_rate.mean())
        audio_features['zero_crossing_rate_var'] = float(zero_crossing_rate.var())

        harmony, perceptr = librosa.effects.hpss(y, margin=3.0)
        audio_features['harmony_mean'] = float(harmony.mean())
        audio_features['harmony_var'] = float(harmony.var())
        audio_features['perceptr_mean'] = float(perceptr.mean())
        audio_features['perceptr_var'] = float(perceptr.var())

        tempo, _ = librosa.beat.beat_track(y=y, sr=sr)
        audio_features['tempo'] = float(tempo)
        mfcc = librosa.feature.mfcc(y=y, sr=sr)

    

        for i in range(len(mfcc)):
            mfcc_mean = 'mfcc' + str(i + 1) + '_mean'
            mfcc_var = 'mfcc' + str(i + 1) + '_var'
            audio_features[mfcc_mean] = float(mfcc[i].mean())
            audio_features[mfcc_var] = float(mfcc[i].var())

        return audio_features

    def inserting(self,path):   
        juhyun = []
        for i in tqdm(range(len(path))):
            juhyun.append(self.extract_features(path[i]))

        juhyun = pd.DataFrame(juhyun)
        
        
        name = juhyun['name']
        vec = juhyun.drop('name',axis=1)
        data = vec.values.tolist()
        
        index = self.pc.Index('test')
        ids = [str(x) for x in range(len(data))]
        meta_datas = [{'text':i} for i in name]
        
        batch_size = 1000
        for i in tqdm(range(0, len(data), batch_size)):
            batch_ids = ids[i:i + batch_size]
            batch_data = data[i:i + batch_size]
            batch_meta_datas = meta_datas[i:i + batch_size]
            records = zip(batch_ids, batch_data, batch_meta_datas)
            index.upsert(vectors=records)



if __name__ == "__main__":
    path = glob('./USER_PATH/*.wav')
    InsertMusic.inserting(path)

