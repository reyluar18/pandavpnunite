�
    B��fV  �                   �P  � d dl Z d dlZd dlZd dlZd dlZd dlZd dlmZ  ed�  �         dZ	  e	ej
        d         �  �        Zn	#  dZY nxY wdZdZd	Zd
ZdZd ee�  �        z   dz   Z G d� dej        �  �        Z G d� dej        �  �        Zeefd�Zedk    r e�   �          dS dS )�    N)�system�clearz0.0.0.0�   i@  � i @  �<   z+Socks Via OVPN, Powered by: Panda VPN Unitez0.0.0.0:1195zHTTP/1.1 200 z

c                   �2   � e Zd Zd� Zd� Zd� Zd� Zd� Zd� ZdS )�Serverc                 ��   � t           j        �                    | �  �         d| _        || _        || _        g | _        t          j        �   �         | _        t          j        �   �         | _	        d S �NF)
�	threading�Thread�__init__�running�host�port�threads�Lock�threadsLock�logLock)�selfr   r   s      �	source.pyr   zServer.__init__   sX   � ���!�!�$�'�'�'������	���	����$�>�+�+��� �~�'�'�����    c                 �  � t          j         t           j        �  �        | _        | j        �                    t           j        t           j        d�  �         | j        �                    d�  �         | j        �                    | j        | j	        f�  �         | j        �
                    d�  �         d| _        	 | j        r�	 | j        �                    �   �         \  }}|�                    d�  �         n# t           j        $ r Y �Kw xY wt          || |�  �        }|�                    �   �          | �                    |�  �         | j        ��d| _        | j        �                    �   �          d S # d| _        | j        �                    �   �          w xY w)Nr   �   r   TF)�socket�AF_INET�soc�
setsockopt�
SOL_SOCKET�SO_REUSEADDR�
settimeout�bindr   r   �listenr   �accept�setblocking�timeout�ConnectionHandler�start�addConn�close)r   �c�addr�conns       r   �runz
Server.run&   sd  � ��=���0�0�������F�-�v�/B�A�F�F�F�����A��������t�y�$�)�,�-�-�-������������	��,� 	#��"�h�o�o�/�/�G�A�t��M�M�!�$�$�$�$���~� � � ��H����� )��D�$�7�7���
�
�������T�"�"�"� �,� 	#� !�D�L��H�N�N������� !�D�L��H�N�N�������s1   �6E( �>1C0 �/E( �0D�?E( �D�AE( �("F
c                 �   � | j         �                    �   �          t          |�  �         | j         �                    �   �          d S �N)r   �acquire�print�release)r   �logs     r   �printLogzServer.printLog=   s;   � ���������c�
�
�
���������r   c                 ��   � 	 | j         �                    �   �          | j        r| j        �                    |�  �         | j         �                    �   �          d S # | j         �                    �   �          w xY wr0   )r   r1   r   r   �appendr3   �r   r-   s     r   r)   zServer.addConnB   sr   � �	'���$�$�&�&�&��|� *���#�#�D�)�)�)���$�$�&�&�&�&�&��D��$�$�&�&�&�&���s   �:A �A2c                 ��   � 	 | j         �                    �   �          | j        �                    |�  �         | j         �                    �   �          d S # | j         �                    �   �          w xY wr0   )r   r1   r   �remover3   r8   s     r   �
removeConnzServer.removeConnJ   sh   � �	'���$�$�&�&�&��L����%�%�%���$�$�&�&�&�&�&��D��$�$�&�&�&�&���s   �3A �A+c                 �  � 	 d| _         | j        �                    �   �          t          | j        �  �        }|D ]}|�                    �   �          �	 | j        �                    �   �          d S # | j        �                    �   �          w xY wr   )r   r   r1   �listr   r*   r3   )r   r   r+   s      r   r*   zServer.closeQ   s�   � �	'� �D�L���$�$�&�&�&��4�<�(�(�G�� � �����	�	�	�	�� ��$�$�&�&�&�&�&��D��$�$�&�&�&�&���s   �AA+ �+BN)	�__name__�
__module__�__qualname__r   r.   r5   r)   r;   r*   � r   r   r	   r	      sn   � � � � � �(� (� (�� � �.� � �
'� '� '�'� '� '�	'� 	'� 	'� 	'� 	'r   r	   c                   �8   � e Zd Zd� Zd� Zd� Zd� Zd� Zd� Zd� Z	dS )	r'   c                 �   � t           j        �                    | �  �         d| _        d| _        || _        d| _        || _        dt          |�  �        z   | _	        d S )NFTr   z	Conexao: )
r   r   r   �clientClosed�targetClosed�client�client_buffer�server�strr4   )r   �	socClientrH   r,   s       r   r   zConnectionHandler.__init__^   sU   � ���!�!�$�'�'�'�!��� ��������������T���*����r   c                 �  � 	 | j         s=| j        �                    t          j        �  �         | j        �                    �   �          n#  Y nxY wd| _         n# d| _         w xY w	 | j        s=| j        �                    t          j        �  �         | j        �                    �   �          n#  Y nxY wd| _        d S # d| _        w xY w)NT)rD   rF   �shutdownr   �	SHUT_RDWRr*   rE   �target)r   s    r   r*   zConnectionHandler.closeg   s�   � �	%��$� $���$�$�V�%5�6�6�6���!�!�#�#�#���	��D���� $�D�����D��$�$�$�$�	%��$� $���$�$�V�%5�6�6�6���!�!�#�#�#���	��D���� $�D������D��$�$�$�$s=   �AA �A �A�	A �	A�#AB( �'B8 �(B,�*B8 �8	Cc                 �  � 	 | j         �                    t          �  �        | _        | �                    | j        d�  �        }|dk    rt
          }| �                    | j        d�  �        }|dk    r| j         �                    t          �  �         |dk    r�| �                    | j        d�  �        }t          t          �  �        dk    r!|t          k    r| �                    |�  �         n=t          t          �  �        dk    r%|t          k    r| j         �	                    d�  �         |�
                    t          �  �        r| �                    |�  �         nD| j         �	                    d�  �         n)t          d�  �         | j         �	                    d	�  �         nV# t          $ rI}| xj        d
t          |�  �        z   z  c_        | j        �                    | j        �  �         Y d }~nd }~ww xY w| �                    �   �          | j        �                    | �  �         d S # | �                    �   �          | j        �                    | �  �         w xY w)NzX-Real-Hostr   zX-SplitzX-Passr   s   HTTP/1.1 400 WrongPass!

s   HTTP/1.1 403 Forbidden!

z- No X-Real-Host!s   HTTP/1.1 400 NoXRealHost!

z
 - error: )rF   �recv�BUFLENrG   �
findHeader�DEFAULT_HOST�len�PASS�method_CONNECT�send�
startswith�IPr2   �	Exceptionr4   rI   rH   r5   r*   r;   )r   �hostPort�split�passwd�es        r   r.   zConnectionHandler.runz   s  � �"	)�!%��!1�!1�&�!9�!9�D�����t�'9�=�I�I�H��2�~�~�'���O�O�D�$6�	�B�B�E���{�{��� � ��(�(�(��2�~�~�����);�X�F�F���t�9�9��>�>�f��n�n��'�'��1�1�1�1���Y�Y�!�^�^��$����K�$�$�%G�H�H�H��&�&�r�*�*� I��'�'��1�1�1�1��K�$�$�%G�H�H�H�H��)�*�*�*��� � �!E�F�F�F���� 	� 	� 	��H�H��s�1�v�v�-�-�H�H��K� � ���*�*�*��D�D�D�D�����	����
 �J�J�L�L�L��K�"�"�4�(�(�(�(�(�� �J�J�L�L�L��K�"�"�4�(�(�(�(���s0   �FF �H  �
G-�$?G(�#H  �(G-�-H  � 0Ic                 ��   � |�                     �   �         }|�                    |dz   �  �        }|dk    rdS |�                    d|�  �        }||dz   d �         }|�                    d�  �        }|dk    rdS |d |�         S )Ns   : �����r   �   :r   s   
)�encode�find)r   �head�header�auxs       r   rR   zConnectionHandler.findHeader�   s�   � ��������i�i����'�'���"�9�9��2��i�i��c�"�"���C��E�F�F�|���i�i�� � ���"�9�9��2��D�S�D�z�r   c                 �`  � |�                     d�  �        }|dk    r%t          ||dz   d �         �  �        }|d |�         }n| j        dk    rd}nd}t          j        ||�  �        d         \  }}}}}t          j        |||�  �        | _        d| _        | j        �                    |�  �         d S )	N�:r`   r   �CONNECT�n   �   r   F)rc   �int�methodr   �getaddrinforN   rE   �connect)	r   r   �ir   �
soc_family�soc_type�proto�_�addresss	            r   �connect_targetz ConnectionHandler.connect_target�   s�   � ��I�I�c�N�N����7�7��t�A�a�C�D�D�z�?�?�D�����8�D�D��{�i�'�'������4:�4F�t�T�4R�4R�ST�4U�1��X�u�a���m�J��%�@�@���!�������G�$�$�$�$�$r   c                 �,  � | xj         d|z   z  c_         | �                    |�  �         | j        �                    t          �                    �   �         �  �         d| _        | j        �                    | j         �  �         | �	                    �   �          d S )Nz - CONNECT r   )
r4   rv   rF   �sendall�RESPONSErb   rG   rH   r5   �	doCONNECT)r   �paths     r   rV   z ConnectionHandler.method_CONNECT�   s�   � ����M�D�(�(������D�!�!�!�����H�O�O�-�-�.�.�.��������T�X�&�&�&��������r   c                 �  � | j         | j        g}d}d}	 |dz  }t          j        |g |d�  �        \  }}}|rd}|r}|D ]z}	 |�                    t          �  �        }|rO|| j        u r| j         �                    |�  �         n(|r&| j        �                    |�  �        }	||	d �         }|�&d}n n�q#  d}Y  nxY w|t          k    rd}|rd S ��)Nr   FTr   �   )rF   rN   �selectrP   rQ   rW   �TIMEOUT)
r   �socs�count�errorrP   rt   �err�in_�data�bytes
             r   rz   zConnectionHandler.doCONNECT�   s)  � ���T�[�)������	��Q�J�E�#�]�4��T�1�=�=�N�T�1�c�� ���� �� � �C��"�x�x��/�/��� 
"�"�d�k�1�1� $�� 0� 0�� 6� 6� 6� 6�&*� !7�+/�;�+;�+;�D�+A�+A�D�+/����;�D� '+� !7� %&�E�E�!�E� "��� $��������������� ���7	s   �A+B-�-B4N)
r>   r?   r@   r   r*   r.   rR   rv   rV   rz   rA   r   r   r'   r'   ]   s~   � � � � � �+� +� +�%� %� %�&#)� #)� #)�J� � �"%� %� %�"� � �� � � � r   r'   c                 �  � t          dddd�  �         t          dt          z   �  �         t          dt          t          �  �        z   dz   �  �         t          dddd�  �         t	          t          t          �  �        }|�                    �   �          	 	 t          j        d
�  �         n4# t          $ r' t          d�  �         |�	                    �   �          Y d S w xY w�K)NuP   [0;34m━[0;34m━[0;34m━[0;34m━[0;34m━[0;34m━[0;34m━[0;34m━z[1;32m PROXY SOCKS�
z[1;33mIP:[1;32m z[1;33mPORTA:[1;32m ud   [0;34m━[0;34m━[0;34m━[0;34m━[0;34m━[0;34m━[0;34m━[0;34m━[0;34m━[0;34m━z[1;32m Panda VPN Uniteu�   [0;34m━[1;37m[0;34m━[1;37m[0;34m━[1;37m[0;34m━[1;37m[0;34m━[1;37m[0;34m━[1;37m[0;34m━[1;37m[0;34m━[1;37m[0;34m━[1;37m[0;34m━[1;37m[0;34m━[1;37mTr   z
Closing...)
r2   rY   rI   �PORTr	   r(   �time�sleep�KeyboardInterruptr*   )r   r   rH   s      r   �mainr�   �   s�   � �	�
�4�5F�t�L�L�L�	�
$�r�
)�*�*�*�	�
'�#�d�)�)�
3�d�
:�;�;�;�	�
�9�:V�W[�\�\�\��B����F�
�L�L�N�N�N��	��J�q�M�M�M�M�� � 	� 	� 	��.�!�!�!��L�L�N�N�N��E�E�	����s   �B( �(-C�C�__main__)r   r   r~   �signal�sysr�   �osr   rY   rl   �argvr�   rU   rQ   r   �MSGrS   rI   ry   r   r	   r'   r�   r>   rA   r   r   �<module>r�      sg  �� ���� � � � � ���� ���� 
�
�
�
� ���� � � � � � � ��w���� ����3�s�x��{���D�D����D�D�D����	��	��
��3�����S�S��X�X�%�
�2��>'� >'� >'� >'� >'�Y�� >'� >'� >'�BK� K� K� K� K�	�(� K� K� K�\ �t� � � � �  �z����D�F�F�F�F�F� �s   �A �A
