package com.qapint.app.phonegap;

import org.apache.cordova.FileProgressResult;
import org.apache.cordova.api.PluginResult;
import com.qapint.app.phonegap.PresentationTransfer.RequestContext;
import org.json.JSONException;

public class TransferNotifier {
    private long totalFileLength = 0;
    private long bytesLoaded = 0;
    private double percentsLoaded = 0;
    private FileProgressResult progress;
    private RequestContext context;

    public TransferNotifier(RequestContext context){
        this.context = context;
        this.progress = new FileProgressResult();
    }

    private void notifyProgress() throws JSONException {
        progress.setLoaded(bytesLoaded);
        PluginResult progressResult = new PluginResult(PluginResult.Status.OK, progress.toJSONObject());
        progressResult.setKeepCallback(true);
        this.context.sendPluginResult(progressResult);
    }

    public void shouldNotify(long bytesRead) throws JSONException{
        if (totalFileLength > 0) {
            double newPercents = ((double)(bytesLoaded+bytesRead) / (double)totalFileLength)*(double)100;
            if ((newPercents - percentsLoaded)>= 0.49 || totalFileLength <= bytesLoaded || bytesLoaded == 0) {
                notifyProgress();
                percentsLoaded = newPercents;
            }
        } else {
            notifyProgress();
        }
        this.bytesLoaded += bytesRead;
    }

    public void setLengthComputable(boolean state){
        this.progress.setLengthComputable(state);
    }

    public void setTotalFileLength(long fileLength){
        this.totalFileLength = fileLength;
        this.progress.setTotal(fileLength);
    }
}
